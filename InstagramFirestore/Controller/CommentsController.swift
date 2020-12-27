//
//  CommentsController.swift
//  InstagramFirestore
//
//  Created by Kunal Tyagi on 17/12/20.
//

import UIKit

// MARK: - Reuse-Identifiers

private let commentCellReuseIdentifier = "commentCell"

class CommentsController: UIViewController {
    // MARK: - Properties
    
    private let tableView = UITableView()
    
    var postId: String?
    var comments: [Comment] = []
    
    private lazy var commentInputView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.height, height: 62.5)
        let cv = CommentInputAccessoryView(frame: frame)
        cv.delegate = self
        return cv
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let postTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Comment", textColor: .label)
        tf.font = UIFont.systemFont(ofSize: 15)
        return tf
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        fetchComments()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - API
    
    func fetchComments() {
        guard let postId = postId else { return }
        CommentService.fetchComment(postId: postId) { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let comments):
                        self.comments = comments
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureView() {
        self.navigationItem.title = "Comments"
        self.navigationItem.backButtonTitle = ""
        self.view.backgroundColor = UIColor(named: "background")
        self.tableView.backgroundColor = UIColor(named: "background")
        
        commentInputView.commentTextField.delegate = self
        
        setConstraintsForView()
        configureTableView()
        setupGestures()
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        commentInputView.commentTextField.resignFirstResponder()
    }
    
    func setConstraintsForView() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func configureTableView() {
        self.tableView.register(CommentCell.self, forCellReuseIdentifier: commentCellReuseIdentifier)
        let footerView = UIView()
        self.tableView.tableFooterView = footerView
        self.tableView.estimatedRowHeight = 30.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = true
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    // MARK: - Actions

}

// MARK: - UITableViewDataSource

extension CommentsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: commentCellReuseIdentifier) as? CommentCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.commentTextView.delegate = self
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CommentsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileLayout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: profileLayout)
        profileController.selectedUserId = comments[indexPath.row].uid
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(profileController, animated: true)
        }
    }
}

// MARK: - UITextViewDelegate

extension CommentsController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("came in this method.")
        if (URL.absoluteString == "https://www.apple.com") {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        return false
    }
}

// MARK: - UITextFieldDelegate

extension CommentsController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return false }
        let numberOfChars = newText.count
        if numberOfChars > 0 {
            commentInputView.postButton.setTitleColor(UIColor.label, for: .normal)
            commentInputView.postButton.isUserInteractionEnabled = true
        } else {
            commentInputView.postButton.setTitleColor(UIColor.label.withAlphaComponent(0.4), for: .normal)
            commentInputView.postButton.isUserInteractionEnabled = false
        }
        return true
    }
}

// MARK: - CommentInputAccessoryViewDelegate

extension CommentsController: CommentInputAccessoryViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {
        guard let postId = postId else { return }
        inputView.clearCommentText()
        let currentUser = User(uid: LoginManager.shared.uid, email: LoginManager.shared.email, username: LoginManager.shared.username, fullName: LoginManager.shared.fullName, profileImageUrl: LoginManager.shared.profileImageUrl)
        CommentService.uploadComment(comment: comment, postId: postId, user: currentUser) { (error) in
            if let error = error {
                inputView.commentTextField.text = comment
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                inputView.commentTextField.resignFirstResponder()
            }
        }
    }
}
