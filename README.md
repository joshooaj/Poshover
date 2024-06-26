<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]
[![Twitter][twitter-shield]][twitter-url]


<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://pushover.net">
    <img src="images/pushover_logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Poshover - A PowerShell Module for Pushover</h3>

  <p align="center">
    Send push notifications to mobile devices and desktops from PowerShell using the Pushover service!
    <br />
    <a href="https://github.com/jhendricks123/Poshover"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/jhendricks123/Poshover/issues">Report Bug</a>
    ·
    <a href="https://github.com/jhendricks123/Poshover/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

## NOTICE

This repository is no longer maintained. The module has been renamed to joshooaj.PSPushover and a [new repository](https://github.com/joshooaj/PSPushover) has been created.
The new repo has a number of improvements including:

- Automatic documentation generation, updating, and publishing using PlatyPS, MkDocs, and GitHub Pages
- Automatic building and testing on Linux, Windows, and MacOS
- Automatic publishing of tagged versions to PSGallery after successfully passing tests
- Automatic versioning using nbgv
- Codespaces or devcontainer support
- Built-in demo showing how a GitHub action runs and sends a notification when the repository gets starred

<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://github.com/jhendricks123/poshover)

If you want to send push notifications to one or more mobile or desktop devices from PowerShell,
that's exactly what this module is about. The module makes use of the Pushover.net notification
service which is _free_ for up to 10k notifications per month!

The goal of the module is to support as much of the Pushover API as possible. To start with, the
messages endpoint is be supported using the Send-Pushover function, and the most common features
including message priority, retry interval, expiration, and attachment capabilities are available.

Later, support will be added for additional features like checking receipt status, listing and
specifying notification sounds, and other API areas like subscriptions, groups, licensing, etc.

<!-- GETTING STARTED -->
## Getting Started

Before you use Poshover and the Pushover API, you need a Pushover account and an application token.

### Prerequisites

You need a Pushover account, a user or group key to which messages will be sent, and an application token to which
1. Go sign up (for free) on [Pushover.net](https://pushover.net/signup) and confirm your email address.
2. Copy your __user key__ and save it for later.
3. Scroll down to __Your Applications__ and click [Create an Application/API Token](https://pushover.net/apps/build).
4. Give it a name (this will be the title of your push notifications when you don't supply your own title)
5. Pick an icon. It's optional, but you really want your own icon :)
6. Read the ToS and check the box, then click __Create Application__
7. Save your __API Token/Key__ for later. You're ready to install and click __Back to apps__ or click on the Pushover logo in the title bar

### Installation

Launch an elevated PowerShell session and run the following:
```powershell
Install-Module -Name Poshover -AllowPrerelease
```

If that failed, you may need to update your PowerShellGet package provider. Try this:
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PowerShellGet -Force
Install-Module -Name Poshover -AllowPrerelease
```

<!-- USAGE EXAMPLES -->
## Usage

Got your application token and user keys handy? Good!
```powershell
$token = Read-Host -Prompt 'Application API Token' -AsSecureString
$user = Read-Host -Prompt 'User Key' -AsSecureString
Send-Pushover -Token $token -User $user -Message 'Have a nice day!'
```

Don't want to enter your token and user keys every time? You don't have to!
```powershell
# This will securely save your token and user keys to %appdata%/Poshover/config.xml
$token = Read-Host -Prompt 'Application API Token' -AsSecureString
$user = Read-Host -Prompt 'User Key' -AsSecureString
Set-PushoverConfig -Token $token -User $user

Send-Pushover -Message 'You are fantastic!'
```

## Building

The structure of the PowerShell module is such that the .\src\ directory contains the module manifest,
.psm1 file, and all other functions/classes/tests necessary. The "build" process takes the content
of the .\src\ directory, copies it to .\output\Poshover\version\, and updates the module manifest to
ensure all classes and functions are exported properly.

To build, simply run `Invoke-psake build` from the root of the project. And to test, run `Invoke-psake test`.

I like to also setup VSCode to launch .\debug.ps1 when I press F5. This will clear the .\output\ directory
and call the psake build task, then force-import the updated module from the .\output\ directory. I find this
makes the developer "inner-loop" really quick.

Also, I recommend using the Microsoft.Powershell.SecretManagement module for storing your api keys. That way
you never enter them in clear text.

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/jhendricks123/Poshover/issues) for a list of proposed features (and known issues).


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.


<!-- CONTACT -->
## Contact

Josh Hendricks - [@joshooaj](https://twitter.com/@joshooaj)

Project Link: [https://github.com/jhendricks123/Poshover](https://github.com/jhendricks123/Poshover)


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [othneildrew's Best-README-Template](https://github.com/othneildrew/Best-README-Template)
* [Pushover.net's great documentation](https://pushover.net)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/jhendricks123/poshover.svg?style=for-the-badge
[contributors-url]: https://github.com/jhendricks123/poshover/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/jhendricks123/poshover.svg?style=for-the-badge
[forks-url]: https://github.com/jhendricks123/poshover/network/members
[stars-shield]: https://img.shields.io/github/stars/jhendricks123/poshover.svg?style=for-the-badge
[stars-url]: https://github.com/jhendricks123/poshover/stargazers
[issues-shield]: https://img.shields.io/github/issues/jhendricks123/poshover.svg?style=for-the-badge
[issues-url]: https://github.com/jhendricks123/poshover/issues
[license-shield]: https://img.shields.io/github/license/jhendricks123/poshover.svg?style=for-the-badge
[license-url]: https://github.com/jhendricks123/poshover/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/joshuahendricks/
[twitter-shield]: https://img.shields.io/badge/-Twitter-black.svg?style=for-the-badge&logo=twitter&colorB=555
[twitter-url]: https://twitter.com/joshooaj
[product-screenshot]: images/screenshot.png
