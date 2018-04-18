# Deprecator

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5ad768595918c10001e582cd&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5ad768595918c10001e582cd/build/latest?branch=master)

**Deprecation handler for iOS**

Deprecator automatically handles version checking against a hosted JSON file and handles soft and hard deprecation of old release builds of your app.

* Hard/Soft deprecation
* Built-in UI
* Internationalisation
* Informative errors

## Install

```
github "reddavis/Deprecator-iOS"
```

## Example

Let’s initialize the Deprecator:

```
self.deprecator = Deprecator(deprecationURL: url, currentBuildNumber: 47)
self.deprecator.delegate = self
```

and a few data source and delegate methods:

```
// MARK: DeprecatorDelegate

func didFind(deprecation: Deprecator.Deprecation, isRequired: Bool, in deprecator: Deprecator)
{
    deprecation.present(in: self.rootViewController, language: "fr")
}

func didFail(with error: Deprecator.DataError, in deprecator: Deprecator)
{
    //…
}

func didNotFindDeprecation(in deprecator: Deprecator)
{
    //…
}
```

To trigger a check for deprecations:

```
self.deprecator.checkForDeprecations()
```

## Deprecator JSON

The JSON file should look like

```
{
    "meta": {
        "version": 1
    },
    "minimum_update": {
        "build_number": 48,
        "default_language": "en",
        "url": "https://red.to",
        "strings": {
            "en": {
                "title": "englishTitle",
                "update_action_title": "englishUpdateTitle",
                "message": "englishMessage"
            },
            "fr": {
                "title": "frenchTitle",
                "update_action_title": "frenchUpdateTitle",
                "message": "frenchMessage"
            }
        }
    },
    "preferred_update": {
        "build_number": 61,
        "default_language": "de",
        "url": "https://red.to",
        "strings": {
            "en": {
                "title": "englishTitle",
                "update_action_title": "englishUpdateTitle",
                "cancel_action_title": "englishCancelTitle",
                "message": "englishMessage"
            },
            "fr": {
                "title": "frenchTitle",
                "update_action_title": "frenchUpdateTitle",
                "cancel_action_title": "frenchCancelTitle",
                "message": "frenchMessage"
            },
            "de": {
                "title": "germanTitle",
                "update_action_title": "germanUpdateTitle",
                "cancel_action_title": "germanCancelTitle",
                "message": "germanMessage"
            }
        }
    }
}

```

## License

[MIT License](http://www.opensource.org/licenses/MIT).
