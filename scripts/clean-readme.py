import re

with open("README.md", "r", encoding="utf-8") as readme_file:
    original_content = readme_file.read()

cleaned_content = re.sub(
    r"<!--\s*MODRINTH_REMOVE_START\s*-->.*?<!--\s*MODRINTH_REMOVE_END\s*-->",
    "",
    original_content,
    flags=re.DOTALL,
)

output_path = "assets/README-modrinth.md"
with open(output_path, "w", encoding="utf-8") as modrinth_file:
    modrinth_file.write(cleaned_content)

print(f"Cleaned README saved to {output_path}")
