<p align="center">
  <img src="assets/starlight.png" alt="Starlight Banner" width="80%">
</p>
<h1 align="center">𝙎𝙏𝘼𝙍𝙇𝙄𝙂𝙃𝙏</h1>

<p align="center">
  <a href="https://fabricmc.net/">
    <img src="https://img.shields.io/badge/Fabric-0.16.10-blueviolet?logo=fabric&logoColor=white" alt="Fabric Version">
  </a>
  <a href="https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21">
    <img src="https://img.shields.io/badge/Minecraft-1.21-green?logo=minecraft" alt="Minecraft">
  </a>
  <a href="https://modrinth.com/modpack/YOUR-SLUG">
    <img src="https://img.shields.io/badge/Modrinth-Published-5da545?logo=modrinth&logoColor=white" alt="Modrinth">
  </a>
  <a href="https://packwiz.infra.link/">
    <img src="https://img.shields.io/badge/built%20with-packwiz-9146ff?logo=go&logoColor=white" alt="Packwiz">
  </a>
</p>

This modpack is built to feel like **Minecraft, but smoother and faster** — a seamless blend of vanilla fidelity and technical power.

### ✨ Features:

* ⚙️ **Performance** — powered by mods like Sodium, Lithium, and FerriteCore for a lightweight, high-FPS experience
* 🧠 **Technical utility** — includes tools like Carpet, MiniHUD, WorldEdit, and others for redstoners and world builders
* 💖 **Quality of life** — better UI, tooltips, world maps, and helpful tweaks without disrupting the vanilla flow

🎨 Designed to stay **true to vanilla**, while offering subtle enhancements for players who want more — without *feeling* like a modded pack.

## 📦 Installation

### 💚 Modrinth Launcher (Recommended)

1. Install the [Modrinth App](https://modrinth.com/app)
2. Search for **Starlight**, or visit [the website](https://modrinth.com/modpack/YOUR-SLUG)
3. Click **Install**
4. Launch and enjoy!

### ⚙️ Manual with Packwiz

If you're contributing to development or want full control:

1. [Install Packwiz](https://packwiz.infra.link/installation/)
2. Clone this repo:

   ```bash
   git clone https://github.com/YOUR-USERNAME/starlight-modpack.git
   cd starlight-modpack
   ```
3. Refresh mods and download them:

   ```bash
   packwiz refresh
   ```

## 🧑‍💻 Development Guide

Starlight uses [Packwiz](https://packwiz.infra.link/) for modpack management. This allows simple mod additions, version locking, and repeatable builds via Git.

### ᴝ️ Add a New Mod from Modrinth

```bash
packwiz modrinth add <mod-slug>
```

💡 You can specify a version:

```bash
packwiz modrinth add <mod-slug> --version <modrinth-version-id>
```

This will create a `.toml` file in `mods/` and fetch the correct file.

### ↔️ Update All Mods

```bash
packwiz update --all
```

### 📆 Export for Modrinth

To generate a `.mrpack` file for Modrinth or manual distribution:

```bash
packwiz mr export
```

This will include:

* All mod `.jar` links and metadata
* Everything from the `overrides/` folder (config, resourcepacks, etc.)

## 📜 Mod List

*(Coming soon – will include full mod names with Modrinth links)*

## 🌐 Resources

This modpack uses open-source mods, resource packs, datapacks, and shaders from [Modrinth](https://modrinth.com/), a community-driven platform for Minecraft modding.

All mods are managed via [Packwiz](https://packwiz.infra.link/), ensuring safe, reproducible builds and easy updates.

To sync or re-download all dependencies:

```bash
packwiz refresh
```

## 🧷 License

This project is open-source and intended for educational and personal use. All mods included remain under their respective licenses. Be kind, give credit, and have fun 🌱
