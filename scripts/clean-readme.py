import re

# Open the original README file and read its content
with open("README.md", "r", encoding="utf-8") as readme_file:
    original_content = readme_file.read()

# Define a regular expression to match and remove content between special markers
# <!-- MODRINTH_REMOVE_START --> and <!-- MODRINTH_REMOVE_END -->
cleaned_content = re.sub(
    r"<!--\s*MODRINTH_REMOVE_START\s*-->.*?<!--\s*MODRINTH_REMOVE_END\s*-->",
    "",  # Replace matched content with an empty string
    original_content,
    flags=re.DOTALL,  # Enable matching across multiple lines
)

# Save the cleaned content to a new file for Modrinth
output_path = "assets/README-modrinth.md"
with open(output_path, "w", encoding="utf-8") as modrinth_file:
    modrinth_file.write(cleaned_content)

print(f"Cleaned README saved to {output_path}")
