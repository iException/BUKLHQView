##BUKLHQView
### 百姓life拨号盘分离代码， swift版
## use
```swift
// MARK: BUKLHQViewDelegate
func buk_lhqView(lhqView: BUKLHQView, didSelectButtonAtIndex index: Int) {
    print(index)
}
// MARK: BUKLHQViewDataSource
func buk_numberOfButtonsInLHQView(lhqView: BUKLHQView) -> Int {
    return 6
}

func buk_lhqView(lhqView: BUKLHQView, titleForButtonAtIndex index: Int) -> String? {
    return "wtf"
}

func buk_lhqView(lhqView: BUKLHQView, imageForButtonAtIndex index: Int) -> UIImage? {
    return nil
}

func buk_lhqView(lhqView: BUKLHQView, titleColorForButtonAtIndex index: Int) -> UIColor? {
    return UIColor.black()
}
```
