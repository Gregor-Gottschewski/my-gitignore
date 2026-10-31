# My Gitignore
> Manage and create .gitignore files.

What is the first thing you should do before committing your project? Right! **Creating a .gitignore file.** Some IDEs and frameworks create one automatically when you start a new project. However, it often doesn't cover all unwanted files. In these cases people rely on [gitignore.io](https://www.toptal.com/developers/gitignore), where you create gitignore files based on keywords. We bring the same technique natively to the Mac!

## How does it work?
When you start My Gitignore for the first time, the gitignore templates from [GitHub](https://github.com/github/gitignore) are downloaded. You can then combine them into your own gitignore files, like on gitignore.io. The templates are checked for updates once a day.

## Requirements
- macOS (see the deployment target in the Xcode project)
- An internet connection for the first launch and for template updates

## Building
1. Open `My Gitignore.xcodeproj` in Xcode.
2. Select the **My Gitignore** scheme and run it.

Swift Package Manager fetches the only dependency, [ZIPFoundation](https://github.com/weichsel/ZIPFoundation), automatically.

## Privacy
My Gitignore collects no data. The only network requests go to `github.com` and `api.github.com` to download and update the templates.

## Credits and licenses
- Templates: [github/gitignore](https://github.com/github/gitignore) (CC0 1.0)
- [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) (MIT License)

This project is not affiliated with or endorsed by GitHub, Inc. See [LICENSE](LICENSE.md) for the license of this project.
