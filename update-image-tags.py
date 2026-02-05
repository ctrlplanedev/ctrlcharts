#!/usr/bin/env python3
"""
Script to fetch the latest Docker image tags from Docker Hub and update local-values.yaml
"""

import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set

import requests
import yaml


class DockerHubAPI:
    """Docker Hub API client"""
    
    BASE_URL = "https://hub.docker.com/v2"
    
    def get_latest_tag(self, repository: str, namespace: str = "ctrlplane") -> Optional[str]:
        """
        Get the latest tag for a Docker Hub repository.
        
        Args:
            repository: Repository name (e.g., 'api', 'web')
            namespace: Docker Hub namespace (default: 'ctrlplane')
            
        Returns:
            Latest tag or None if not found
        """
        url = f"{self.BASE_URL}/repositories/{namespace}/{repository}/tags"
        params = {
            "page_size": 100,
            "ordering": "last_updated"  # This gets the most recently updated tags first
        }
        
        try:
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            tags = data.get("results", [])
            
            if not tags:
                print(f"Warning: No tags found for {namespace}/{repository}")
                return None
            
            # Debug: show first few tags to understand what we're getting
            print(f"  First few tags for {namespace}/{repository}:")
            for i, tag in enumerate(tags[:5]):
                print(f"    {i+1}. {tag['name']} (updated: {tag.get('last_updated', 'unknown')})")
            
            # Filter out 'latest' tag and look for commit-like tags (short hashes)
            # Since we're ordering by -last_updated, the first matching tag is the newest
            for tag in tags:
                tag_name = tag["name"]
                if tag_name != "latest" and self._is_commit_tag(tag_name):
                    print(f"  Selected newest commit tag: {tag_name}")
                    return tag_name
                     
            # If no commit-like tag found, return the first non-latest tag
            for tag in tags:
                tag_name = tag["name"]
                if tag_name != "latest":
                    print(f"  Selected newest non-latest tag: {tag_name}")
                    return tag_name
                    
            print(f"Warning: No suitable tags found for {namespace}/{repository}")
            return None
            
        except requests.RequestException as e:
            print(f"Error fetching tags for {namespace}/{repository}: {e}")
            return None
    
    def _is_commit_tag(self, tag: str) -> bool:
        """Check if tag looks like a git commit hash (6-8 alphanumeric characters)"""
        return bool(re.match(r'^[a-f0-9]{6,8}$', tag))


class LocalValuesUpdater:
    """Updates local-values.yaml with new image tags"""
    
    def __init__(self, values_file: Path, only_services: Optional[Set[str]] = None):
        self.values_file = values_file
        self.docker_api = DockerHubAPI()
        self.only_services = only_services
        
        # Map of service names to their Docker Hub repository names
        self.service_to_repo = {
            "web": "web",
            "api": "api", 
            "workspace-engine-router": "workspace-engine-router",
            "workspace-engine": "workspace-engine",
            "event-queue": "event-queue",
            "event-worker": "event-worker",  # Note: not in values files but in local-values
            "jobs": "jobs",
            "migrations": "migrations",
            "pty-proxy": "pty-proxy",
            "webservice": "webservice"
        }
    
    def load_values(self) -> Dict:
        """Load the current values from local-values.yaml"""
        try:
            with open(self.values_file, 'r') as f:
                return yaml.safe_load(f) or {}
        except FileNotFoundError:
            print(f"Error: {self.values_file} not found")
            sys.exit(1)
        except yaml.YAMLError as e:
            print(f"Error parsing YAML: {e}")
            sys.exit(1)
    
    def save_values(self, values: Dict) -> None:
        """Save the updated values to local-values.yaml"""
        try:
            with open(self.values_file, 'w') as f:
                yaml.dump(values, f, default_flow_style=False, sort_keys=False)
            print(f"Successfully updated {self.values_file}")
        except Exception as e:
            print(f"Error saving values: {e}")
            sys.exit(1)
    
    def get_available_services(self) -> List[str]:
        """Get list of available services that can be updated"""
        return list(self.service_to_repo.keys())
    
    def validate_services(self, services: Set[str]) -> None:
        """Validate that all requested services are available"""
        available_services = set(self.service_to_repo.keys())
        invalid_services = services - available_services
        
        if invalid_services:
            print(f"Error: Unknown services: {', '.join(sorted(invalid_services))}")
            print(f"Available services: {', '.join(sorted(available_services))}")
            sys.exit(1)
    
    def update_image_tags(self) -> None:
        """Update image tags in local-values.yaml"""
        print("Loading current values...")
        values = self.load_values()
        
        # Determine which services to update
        services_to_update = self.service_to_repo.items()
        if self.only_services:
            self.validate_services(self.only_services)
            services_to_update = [(name, repo) for name, repo in self.service_to_repo.items() 
                                if name in self.only_services]
            print(f"Updating only: {', '.join(sorted(self.only_services))}")
        else:
            print("Updating all services...")
        
        updated_services = []
        
        for service_name, repo_name in services_to_update:
            if service_name in values and isinstance(values[service_name], dict):
                print(f"\nChecking {service_name}...")
                
                # Get latest tag from Docker Hub
                latest_tag = self.docker_api.get_latest_tag(repo_name)
                
                if latest_tag:
                    # Ensure image section exists
                    if "image" not in values[service_name]:
                        values[service_name]["image"] = {}
                    
                    # Get current tag
                    current_tag = values[service_name]["image"].get("tag", "unknown")
                    
                    # Update tag if different
                    if current_tag != latest_tag:
                        values[service_name]["image"]["tag"] = latest_tag
                        updated_services.append(f"{service_name}: {current_tag} -> {latest_tag}")
                        print(f"  Updated {service_name}: {current_tag} -> {latest_tag}")
                    else:
                        print(f"  {service_name} already up to date: {current_tag}")
                else:
                    print(f"  Could not fetch latest tag for {service_name}")
            elif self.only_services and service_name in self.only_services:
                print(f"\nWarning: Service '{service_name}' not found in local-values.yaml")
        
        if updated_services:
            print(f"\nUpdating {len(updated_services)} services:")
            for update in updated_services:
                print(f"  - {update}")
            
            self.save_values(values)
        else:
            print("\nNo updates needed - all services are up to date!")


def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Update Docker image tags in local-values.yaml from Docker Hub",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           # Update all services
  %(prog)s --only web,api            # Update only web and api services
  %(prog)s --list                    # List available services
        """
    )
    
    parser.add_argument(
        "--only",
        type=str,
        help="Comma-separated list of services to update (e.g., 'web,api,jobs')"
    )
    
    parser.add_argument(
        "--list",
        action="store_true",
        help="List available services and exit"
    )
    
    return parser.parse_args()


def main():
    """Main entry point"""
    args = parse_args()
    
    script_dir = Path(__file__).parent
    values_file = script_dir / "charts" / "ctrlplane" / "local-values.yaml"
    
    if not values_file.exists():
        print(f"Error: {values_file} does not exist")
        sys.exit(1)
    
    # Create updater to get available services
    updater = LocalValuesUpdater(values_file)
    
    # Handle --list option
    if args.list:
        print("Available services:")
        for service in sorted(updater.get_available_services()):
            print(f"  - {service}")
        return
    
    # Parse --only option
    only_services = None
    if args.only:
        only_services = set(service.strip() for service in args.only.split(','))
        if not only_services:
            print("Error: --only requires at least one service name")
            sys.exit(1)
    
    # Update the updater with the filtered services
    updater = LocalValuesUpdater(values_file, only_services)
    
    print(f"Updating image tags in {values_file}")
    print("=" * 50)
    
    updater.update_image_tags()
    
    print("\nDone!")


if __name__ == "__main__":
    main()
