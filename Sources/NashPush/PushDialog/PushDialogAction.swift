struct PushDialogAction: Equatable {
  static func == (lhs: PushDialogAction, rhs: PushDialogAction) -> Bool {
    return lhs.title == rhs.title
  }

  let title: String
  let action: () -> Void
}
