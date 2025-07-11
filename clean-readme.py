import re

with open("README.md", "r", encoding="utf-8") as f:
    content = f.read()

# Remove all content between the special markers
cleaned = re.sub(
    r"<!--\s*MODRINTH_REMOVE_START\s*-->.*?<!--\s*MODRINTH_REMOVE_END\s*-->",
    "",
    content,
    flags=re.DOTALL,
)

# Save to a new file that we’ll upload to Modrinth
with open("assets/README-modrinth.md", "w", encoding="utf-8") as f:
    f.write(cleaned)
