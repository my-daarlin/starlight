import requests

TARGET_VERSION = "1.21"  # Set your target version here

def version_tuple(version: str):
    return tuple(int(x) for x in version.split("."))

def get_versions_from(target_version: str):
    url = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()

    # Collect release versions
    release_versions = [v["id"] for v in data["versions"] if v["type"] == "release"]

    target_tuple = version_tuple(target_version)
    # Filter versions >= target and sort ascending
    filtered_versions = sorted(
        [v for v in release_versions if version_tuple(v) >= target_tuple],
        key=version_tuple
    )

    for v in filtered_versions:
        print(v)

if __name__ == "__main__":
    get_versions_from(TARGET_VERSION)
