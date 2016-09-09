# Deprecator

[![Build Status](https://travis-ci.org/togethera/Deprecator-iOS.svg?branch=master)](https://travis-ci.org/togethera/Deprecator-iOS)

**Deprecation handler for iOS**

Deprecator automatically handles version checking against a hosted JSON file and handles soft and hard deprecation of old release builds of your app.

* Hard/Soft deprecation
* Built-in UI
* Internationalisation
* Informative errors

## Install

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'Deprecator', :git => 'TODO'
```

## Example

Let’s initialize the Deprecator:

```
self.deprecator = Deprecator(deprecationURL: deprecationURL, dataSource: self)
self.deprecator.delegate = self
```

and a few data source and delegate methods:

```
// MARK: DeprecatorDataSource
    
func currentBuildNumber(deprecator: Deprecator) -> Int
{
	  //…
}

// MARK: DeprecatorDelegate

func deprecator(deprecator: Deprecator, didFindRequiredDeprecation deprecation: Deprecator.Deprecation)
{
    //…
}

func deprecator(deprecator: Deprecator, didFindPreferredDeprecation deprecation: Deprecator.Deprecation)
{
	  //…
}

func deprecatorDidNotFindDeprecation(deprecator: Deprecator)
{
	  //…
}

func deprecator(deprecator: Deprecator, didFailWithError error: Deprecator.Error)
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
                "title": "Please update now",
                "update_option": "Update",
                "message": "This version is no longer supported. Please update to the latest version."
            },
            "fr": {
                "title": "Please update now",
                "update_option": "Update",
                "message": "This version is no longer supported. Please update to the latest version."
            }
        }
    },
    "preferred_update": {
        "build_number": 61,
        "default_language": "en",
        "url": "https://red.to",
        "strings": {
            "en": {
                "title": "Please update now",
                "update_option": "Update",
                "cancel_option": "Cancel",
                "message": "This version is no longer supported. Please update to the latest version."
            },
            "fr": {
                "title": "Je suis update now",
                "update_option": "Update",
                "cancel_option": "Cancel",
                "message": "Le version is no longer supported. Please update to the latest version."
            }
        }
    }
}
```

## License

[MIT License](http://www.opensource.org/licenses/MIT).
