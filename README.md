<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/jhendricks123/Poshover">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Poshover - A PowerShell Module for Pushover</h3>

  <p align="center">
    Pushover is an easy-to-use service for sending and receiving mobile and desktop push notifications. They support priority levels, acknowledgements, attachments, group notifications and more. This module helps to make the Pushover API easily accessible in PowerShell from version 5.1 up to PowerShell 7+. Send notifications from PowerShell on Windows, Mac, or Linux, based on whatever you want! Monitor Event Logs, your Twitter feed, your local traffic and weather, your home automation, surveillance or access control, and send notifications to one or more users. Want to build an on-call notification system? Make sure to use the MessagePriority parameter and set it to "Emergency", and your recipients will receive repeated notifications for up to 3 hours.
    <br />
    <a href="https://github.com/jhendricks123/Poshover"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/jhendricks123/Poshover">View Demo</a>
    ·
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

To use this module, you must have an account on [Pushover.net](https://pushover.net) and your own application/api token.
* Create a Pushover.net account
* Create an Application and save your token
* Create a delivery group or acquire one or more user ID's to which notifications should be sent

To clone and develop the module, you should have a handful of PowerShell modules already installed
on your development system.
* psake for build
* Pester for testing
* PSScriptAnalyzer for linting

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

```powershell
Send-Pushover -Token $apikey -User $deliverygroup -Message 'Have a nice day!'
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
[product-screenshot]: images/screenshot.png