SBSegmentedViewController
=========================

`SBSegmentedViewController` is a custom view controller container that uses a segmented control to switch between view controllers.

## Use

`SBSegmentedViewController` is very easy to use. You create your view controllers however you'd like; storyboards, NIBs, or programmatically. Put them in an `NSArray` and init `SBSegmentedViewController` with that array.

Note that since the segmented control can only be put in the `titleView` of a `UINavigationItem` or in a `UIToolbar`, `SBSegmentedViewController` must be embedded in a `UINavigationController`. It didn't really make much sense to put the segmented control anywhere else, but if you have any ideas, feel free to fork.

```objective-c
NSArray *vcs = @[vc1, vc2, vc3]; // vc1, vc2, and vc3 are initialized view controllers
SBSegmentedViewController *segmentedVC = [SBSegmentedViewController alloc] initWithViewControllers:vcs];
segmentedVC.position = SBSegmentedViewControllerControlPositionNavigationBar;
segmentedVC.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;

UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:segmentedVC];

// now do something with navigationController that puts it on screen, for example (in application:didFinishLaunchingWithOptions:):

self.window.rootViewController = navigationController;
```

## License

The [MIT license] (http://opensource.org/licenses/MIT) applies to the code distributed in this repo.
