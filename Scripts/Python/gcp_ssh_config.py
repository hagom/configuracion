#!/usr/bin/env python3
"""
GCP SSH Config Generator
========================
Script generico para poblar automaticamente el archivo ~/.ssh/config
con todas las instancias de Compute Engine de los proyectos de GCP
a los que el usuario autenticado tiene acceso.

Funcionalidades:
  - Detecta el usuario autenticado en gcloud.
  - Genera (si no existen) y copia las llaves SSH de GCP a ~/.ssh/GCP.
  - Lista todos los proyectos accesibles.
  - Para cada proyecto, lista las instancias de Compute Engine.
  - Actualiza ~/.ssh/config preservando las entradas que no son de GCP.

Uso:
  python3 gcp_ssh_config.py [--dry-run] [--config PATH] [--key-name NAME]

  --dry-run     Muestra los cambios sin aplicarlos.
  --config      Ruta al archivo SSH config (default: ~/.ssh/config).
  --key-name    Nombre base para las llaves SSH (default: GCP).

Requisitos:
  - gcloud CLI instalado y autenticado (gcloud auth login).
  - Python 3.6+.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


# ─────────────────────────── helpers ───────────────────────────

def run_cmd(
    cmd: list[str], check: bool = True, timeout: int = 120
) -> subprocess.CompletedProcess:
    """Ejecuta un comando y retorna el resultado."""
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    try:
        return subprocess.run(
            cmd, capture_output=True, text=True, check=check,
            timeout=timeout, env=env,
        )
    except subprocess.TimeoutExpired:
        print(f"  ADVERTENCIA: Timeout ejecutando: {' '.join(cmd)}")
        return subprocess.CompletedProcess(cmd, 1, stdout="", stderr="timeout")


def get_gcp_user() -> str:
    """Obtiene el email del usuario autenticado en gcloud."""
    result = run_cmd(["gcloud", "config", "get-value", "account"])
    email = result.stdout.strip()
    if not email or email == "(unset)":
        print("ERROR: No se ha detectado una cuenta de GCP autenticada.")
        print("       Ejecuta 'gcloud auth login' primero.")
        sys.exit(1)
    return email


def email_to_ssh_user(email: str) -> str:
    """
    Convierte un email de GCP al nombre de usuario SSH.
    Ejemplo: hector.gonzalez@elipse.ai -> hector_gonzalez
    """
    local_part = email.split("@")[0]
    # GCP reemplaza puntos por guiones bajos en el usuario SSH
    return local_part.replace(".", "_")


def get_projects() -> list[dict]:
    """Lista todos los proyectos accesibles."""
    result = run_cmd(
        ["gcloud", "projects", "list", "--format=json(projectId, name)"]
    )
    return json.loads(result.stdout)


def get_instances(project_id: str) -> list[dict]:
    """Lista las instancias de Compute Engine de un proyecto."""
    result = run_cmd(
        [
            "gcloud", "compute", "instances", "list",
            f"--project={project_id}",
            "--format=json(name, networkInterfaces[0].networkIP, status)",
        ],
        check=False,
    )
    if result.returncode != 0:
        # El proyecto podría no tener la API de Compute habilitada
        return []
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return []


# ─────────────────────── SSH key management ────────────────────

def setup_ssh_keys(ssh_dir: Path, key_name: str) -> Path:
    """
    Busca las llaves SSH generadas por GCP y las copia con el nombre indicado.
    Si no existen, las genera.  Retorna la ruta a la llave privada.
    """
    gcp_private = ssh_dir / "google_compute_engine"
    gcp_public = ssh_dir / "google_compute_engine.pub"
    target_private = ssh_dir / key_name
    target_public = ssh_dir / f"{key_name}.pub"

    # Si ya existen las llaves con el nombre objetivo, no hacer nada
    if target_private.exists() and target_public.exists():
        print(f"  Llaves SSH ya existen: {target_private}")
        return target_private

    # Si existen las llaves originales de GCP, copiarlas
    if gcp_private.exists() and gcp_public.exists():
        print(f"  Copiando llaves GCP existentes a {target_private}")
        shutil.copy2(gcp_private, target_private)
        shutil.copy2(gcp_public, target_public)
        os.chmod(target_private, 0o600)
        os.chmod(target_public, 0o644)
        return target_private

    # No existen llaves, generarlas con ssh-keygen
    print(f"  Generando nuevas llaves SSH en {target_private}")
    # Eliminar si existen para evitar prompt de sobrescritura
    if target_private.exists():
        target_private.unlink()
    if target_public.exists():
        target_public.unlink()
    run_cmd([
        "ssh-keygen", "-t", "rsa", "-b", "4096",
        "-f", str(target_private),
        "-N", "",  # sin passphrase
        "-C", f"gcp-ssh-key-{key_name}",
    ])
    os.chmod(target_private, 0o600)
    os.chmod(target_public, 0o644)
    return target_private


# ──────────────────── config file management ───────────────────

GCP_MARKER = "# Maquinas de elipse - GCP"


def read_non_gcp_config(config_path: Path) -> str:
    """Lee el archivo SSH config y retorna solo la parte no-GCP."""
    if not config_path.exists():
        return ""
    content = config_path.read_text()
    if GCP_MARKER in content:
        return content.split(GCP_MARKER)[0]
    return content


def build_host_entry(
    name: str, ip: str, user: str, key_path: str
) -> str:
    """Construye un bloque Host para el archivo SSH config."""
    return (
        f"Host {name}\n"
        f"    Compression yes\n"
        f"    HostName {ip}\n"
        f"    User {user}\n"
        f"    IdentityFile {key_path}\n"
    )


def build_gcp_config(
    projects_instances: dict[str, list[dict]],
    ssh_user: str,
    key_path: str,
) -> str:
    """
    Genera la seccion GCP completa del SSH config.
    projects_instances: {project_id: [instances]}
    """
    sections = []
    for project_id, instances in sorted(projects_instances.items()):
        if not instances:
            continue
        section = f"# Maquinas {project_id}\n"
        for inst in sorted(instances, key=lambda x: x.get("name", "")):
            name = inst.get("name")
            ip = inst.get("networkInterfaces", [{}])[0].get("networkIP")
            if name and ip:
                section += build_host_entry(name, ip, ssh_user, key_path) + "\n"
        sections.append(section)
    return "\n".join(sections)


# ──────────────────────────── main ─────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Genera el archivo SSH config con instancias de GCP."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Muestra los cambios sin aplicarlos.",
    )
    parser.add_argument(
        "--config",
        type=str,
        default=str(Path.home() / ".ssh" / "config"),
        help="Ruta al archivo SSH config.",
    )
    parser.add_argument(
        "--key-name",
        type=str,
        default="GCP",
        help="Nombre base para las llaves SSH.",
    )
    args = parser.parse_args()

    config_path = Path(args.config)
    ssh_dir = Path.home() / ".ssh"

    print("=" * 60)
    print("  GCP SSH Config Generator")
    print("=" * 60)

    # 1. Detectar usuario GCP
    print("\n[1/4] Detectando usuario GCP...")
    email = get_gcp_user()
    ssh_user = email_to_ssh_user(email)
    print(f"  Email: {email}")
    print(f"  Usuario SSH: {ssh_user}")

    # 2. Gestionar llaves SSH
    print(f"\n[2/4] Gestionando llaves SSH ({args.key_name})...")
    key_path = setup_ssh_keys(ssh_dir, args.key_name)
    key_ref = f"~/.ssh/{args.key_name}"

    # 3. Listar proyectos e instancias
    print("\n[3/4] Listando proyectos e instancias de GCP...")
    projects = get_projects()
    print(f"  Proyectos encontrados: {len(projects)}")

    projects_instances: dict[str, list[dict]] = {}
    total_instances = 0
    for proj in projects:
        pid = proj.get("projectId", "")
        pname = proj.get("name", pid)
        instances = get_instances(pid)
        if instances:
            projects_instances[pid] = instances
            total_instances += len(instances)
            print(f"    {pname} ({pid}): {len(instances)} instancias")
        else:
            print(f"    {pname} ({pid}): sin instancias o sin acceso")

    print(f"\n  Total de instancias: {total_instances}")

    # 4. Actualizar SSH config
    print("\n[4/4] Actualizando archivo SSH config...")
    base_config = read_non_gcp_config(config_path)
    gcp_config = build_gcp_config(projects_instances, ssh_user, key_ref)
    full_config = base_config + GCP_MARKER + "\n\n" + gcp_config

    if args.dry_run:
        print("\n--- DRY RUN: contenido que se escribiria ---\n")
        # Solo mostrar la seccion GCP
        print(GCP_MARKER)
        print()
        print(gcp_config)
        print("--- FIN DRY RUN ---")
    else:
        # Crear backup
        if config_path.exists():
            backup = config_path.with_suffix(".config.bak")
            shutil.copy2(config_path, backup)
            print(f"  Backup creado: {backup}")

        config_path.write_text(full_config)
        print(f"  Archivo actualizado: {config_path}")
        print(f"  Entradas GCP generadas: {total_instances}")

    print("\n" + "=" * 60)
    print("  Proceso completado exitosamente!")
    print("=" * 60)


if __name__ == "__main__":
    main()
