<p align="center">
  <img src="https://github.com/my-daarlin/starlight/blob/main/assets/starlight.png?raw=true" alt="Starlight Banner" width="80%">
</p>

<!-- MODRINTH_REMOVE_START -->
<h1 align="center">𝙎𝙏𝘼𝙍𝙇𝙄𝙂𝙃𝙏</h1>
<!-- MODRINTH_REMOVE_END -->

<p align="center">
    <a href="https://fabricmc.net/">
        <img src="https://img.shields.io/badge/Fabric-0.16.14-blueviolet?logo=fabric&logoColor=white" alt="Fabric Version">
    </a>
    <a href="https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21">
        <img src="https://img.shields.io/badge/Minecraft-1.21-green?logo=minecraft" alt="Minecraft">
    </a>
    <a href="https://modrinth.com/project/kWqlGiOE">
        <img src="https://img.shields.io/badge/Modrinth-Published-5da545?logo=modrinth&logoColor=white" alt="Modrinth">
    </a>
    <a href="https://packwiz.infra.link/">
        <img src="https://img.shields.io/badge/built%20with-packwiz-9146ff?logo=go&logoColor=white" alt="Packwiz">
    </a>
    <a href="https://github.com/my-daarlin/starlight">
        <img src="https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white" alt="GitHub">
    </a>
</p>

This modpack is built to feel like **Minecraft, but smoother and faster** — a seamless blend of vanilla fidelity and technical power.

### ✨ Features:

- ⚙️ **Performance** — powered by mods like Sodium, Lithium, and FerriteCore for a lightweight, high-FPS experience
- 🧠 **Technical utility** — includes tools like Carpet, MiniHUD, WorldEdit, and others for redstoners and world builders
- 💖 **Quality of life** — better UI, tooltips, world maps, and helpful tweaks without disrupting the vanilla flow

🎨 Designed to stay **true to vanilla**, while offering subtle enhancements for players who want more — without _feeling_ like a modded pack.

<!-- MODRINTH_REMOVE_START -->

## 📦 Installation

### 💚 Modrinth Launcher (Recommended)

1. Install the [Modrinth App](https://modrinth.com/app)
2. Search for **Starlight**, or visit [the website](https://modrinth.com/project/kWqlGiOE)
3. Click **Install**

---

## 🧑‍💻 Development Guide

Starlight uses [Packwiz](https://packwiz.infra.link/) for modpack management. This allows simple mod additions, version locking, and repeatable builds via Git. To install it, first [install the Go language](https://go.dev/doc/install) and then run this command:

```bash
go install github.com/packwiz/packwiz@latest
```

### 💚 Adding Modrinth content

```bash
packwiz modrinth add <mod-slug>
```

This will create a `.toml` file in `mods/` for the mod.

### 💜 Adding custom content

There is an `override` folder in the project. Everything from there will get merged with the project files during packaging. For example if I have a custom mod, I will place it in `overrides/mods/mod.jar` and during packaging, it will be put into `root/mods`. You can also use it for other custom content, like default option file (should be in `overrides/options.txt`) or the config directory.

### ↔️ Update All Mods

```bash
packwiz update -a
```

### 📆 Export

To generate a `.mrpack` file for Modrinth or manual distribution, use the `package.sh` script. To run it, go to the project root, and execute the following:

```bash
sh package.sh
```

This will include:

- All mod `.jar` links and metadata
- Everything from the `overrides/` folder (config, resourcepacks, etc.)
- Anything else in the repository not included in the `.packwizignore` file

To generate a mod list with mod names and modrinth links (NOT including custom content in `overrides`), run the `generate-modlist.sh` script by running:

```bash
sh generate-modlist.sh
```

> [!NOTE]
> All generated files will be in the `generated` directory

<!-- MODRINTH_REMOVE_END -->

## 📜 Mod List

_(Coming soon – will include full mod names with Modrinth links)_

## 📈 Performance data

_(Coming soon – will include how much fps it gets where)_

<!-- MODRINTH_REMOVE_START -->
<!-- Modrinth has a Gallery tab -->

## 📸 Screenshots

<p align="center">
    <img src="./assets/screenshots/menu.png" alt="Menu Screenshot" width="49%">
    <img src="./assets/screenshots/inventory.png" alt="Inventory Screenshot" width="49%">
</p>
<p align="center">
    <img src="./assets/screenshots/game-day.png" alt="Game Day Screenshot" width="49%">
    <img src="./assets/screenshots/game-night.png" alt="Game Night Screenshot" width="49%">
</p>

<!-- MODRINTH_REMOVE_END -->

## 🌐 Resources

- This modpack uses open-source mods, resource packs, datapacks, and shaders from [Modrinth](https://modrinth.com/), a community-driven platform for Minecraft modding.
- Resource packs from [Vanilla Tweaks](https://vanillatweaks.net/picker/resource-packs/) were used.
- The [Offline Skins](https://www.curseforge.com/minecraft/mc-mods/offlineskins-fabric) mod was used from Curseforge.
- The Starlight logo was created using [Blockbench](https://www.blockbench.net/) with a minecraft text plugin. There is a video explaining how to do this [here](https://www.youtube.com/watch?v=iGaufrACVj4).

All mods are managed via [Packwiz](https://packwiz.infra.link/), ensuring safe, reproducible builds and easy updates.

## 🧷 License

This project is open-source and intended for educational and personal use. All mods included remain under their respective licenses. Be kind, give credit, and have fun 🌱
