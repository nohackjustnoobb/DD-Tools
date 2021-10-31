# DD-Tools

An open source application that allow you to watch multiple streams at the same time. </br>
<i><b>This application will not have any functional update.</b></i>

## Instructions

![Instructions](https://i.imgur.com/IguTcIP.png)

- There are two way to fetch data :

  - using Web Scraper <b>(Default)</b>
  - using Youtube API <b>(Recommended)</b>

  Using API is faster than Web Scraper but you need to provide your own <b>API Key</b></br>If you don't know how to get an API Key, you can follow this [article](https://help.elfsight.com/article/369-how-to-get-your-own-youtube-api-key)

- Some Android device allow multiple player to play sound at the same time. You can try to enable it by setting <b>Force Play Sound</b> (Inside Settings) to <b>true</b>.

## Installation

<details>
            <summary>iOS</summary>
            <p>
            It is hard to install an unsigned app in iOS. There are some way to achieve that without jailbreaking.
            </p>
            <ul>
              <li>You can sign it with your own AppleID and build it. <b>You can follow the Build section below</b></li>
              <li>You can choose your own way to install it with ipa that provided in <a href=
              'https://github.com/nohackjustnoobb/DD-Tools/releases'>Releases</a> <b>(Not Tested)</b></li>
            </ul>
</details>

<details>
            <summary>Android</summary>
            <ul>
                <li>Just download the apk from <a href=
              'https://github.com/nohackjustnoobb/DD-Tools/releases'>Releases</a> and install it</li>
            </ul>
            <p>You may get warning from Play Store beacause I haven't sign the apk. Just ignore it.</p>
</details>

## Build

You need flutter installed already. If you dont, please follow this link: [Flutter Installation](https://flutter.dev/docs/get-started/install)

### Install dependencies

```bash
git clone https://github.com/nohackjustnoobb/DD-Tools.git
```

```bash
cd DD-Tools && flutter pub get
```

### Build

#### Android

<i>Android Studio and its SDK is required.</i>

```bash
flutter build apk
```

#### iOS

<i>macOS and Xcode is required.</br></i>
You may need to open the file `ios/Runner.xcworkspace` to sign it.

```bash
flutter build ios
```

### Install

```bash
flutter install
```

## Know Problems

- iOS devices only allow one player to play sound
- Some android devices only allow the first player that play sound to continue to play sound

You can report bugs in [Issues](https://github.com/nohackjustnoobb/DD-Tools/issues).
