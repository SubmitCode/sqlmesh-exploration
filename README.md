# SQLMesh Exploration

This project explores options for working with [SQLMesh](https://sqlmesh.com/) and [Fabric](https://github.com/danielmiessler/fabric).

## About

SQLMesh is a data transformation framework that brings software engineering best practices to data teams. This repository serves as an exploration space to understand its capabilities and integration options.

## Project Structure

- `config.yaml` - SQLMesh configuration
- `external_models.yaml` - External model definitions
- `models/` - SQL model definitions
- `macros/` - Reusable SQL macros
- `seeds/` - Static data files
- `tests/` - Data quality tests
- `audits/` - Audit configurations

## Getting Started

1. Create a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Initialize SQLMesh:
   ```bash
   sqlmesh init
   ```

## Resources

- [SQLMesh Documentation](https://sqlmesh.readthedocs.io/)
- [Fabric GitHub](https://github.com/danielmiessler/fabric)
