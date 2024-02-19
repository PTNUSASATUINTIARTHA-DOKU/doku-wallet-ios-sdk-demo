//
//  DropDownTextField.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 05/12/23.
//

import UIKit

open class DropDown: UITextField {
    
    //var arrow: Arrow!
    var table: UITableView!
    var shadow: UIView!
    public var selectedIndex: Int?
    public var keyboardIsShown: Bool = false
    
    //MARK: IBInspectable
    @IBInspectable public var rowHeight: CGFloat = 30
    @IBInspectable public var rowBackgroundColor: UIColor = .white
    @IBInspectable public var selectedRowColor: UIColor = .white
    @IBInspectable public var hideOptionsWhenSelect = true
    @IBInspectable public var listHeight: CGFloat = 150
    @IBInspectable public var isAutoClear: Bool = true
    @IBInspectable public var isSearchEnable: Bool = true {
        didSet {
            addTouchActionGesture()
        }
    }
    
    @IBInspectable public var clickedPlaceholder : String = ""
    @IBInspectable public var hideListPlaceholder: String = ""
    @IBInspectable public var isShowKeyboard: Bool = true
    @IBInspectable public var numberLineOfRow: Int = 1
    
    @IBInspectable public var borderColor: UIColor =  UIColor.lightGray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    //Variables
    fileprivate  var tableheightX: CGFloat = 100
    fileprivate  var dataArray = [String]()
    fileprivate  var imageArray = [String]()
    fileprivate  var parentController:UIViewController?
    fileprivate  var pointToParent = CGPoint(x: 0, y: 0)
    fileprivate var backgroundView = UIView()
    fileprivate var keyboardHeight: CGFloat = 0
    
    public var optionArray = [String]() {
        didSet {
            self.dataArray = self.optionArray
        }
    }
    public var optionImageArray = [String]() {
        didSet {
            self.imageArray = self.optionImageArray
        }
    }
    
    public var optionIds: [Int]?
    var searchText = String() {
        didSet {
            if searchText == "" {
                self.dataArray = self.optionArray
            }else{
                self.dataArray = optionArray.filter {
                    return $0.range(of: searchText, options: .caseInsensitive) != nil
                }
            }
            reSizeTable()
            selectedIndex = nil
            self.table.reloadData()
        }
    }
    
    @IBInspectable public var arrowSize: CGFloat = 12 {
        didSet {
//            let center =  arrow.superview!.center
//            arrow.frame = CGRect(x: center.x - arrowSize/2 - 15, y: center.y - arrowSize/2, width: arrowSize, height: arrowSize)
        }
    }
    
    @IBInspectable public var arrowColor: UIColor = .black {
        didSet {
            //arrow.arrowColor = arrowColor
        }
    }
    
    @IBInspectable public var separatorStyle: UITableViewCell.SeparatorStyle = .none
    @IBInspectable public var checkMarkEnabled: Bool = true
    @IBInspectable public var handleKeyboard: Bool = true
    
    // Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.delegate = self
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupUI()
        self.delegate = self
    }

    //MARK: Closures
    fileprivate var didSelectCompletion: (String, Int ,Int) -> () = {selectedText, index , id  in }
    fileprivate var TableWillAppearCompletion: () -> () = { }
    fileprivate var TableDidAppearCompletion: () -> () = { }
    fileprivate var TableWillDisappearCompletion: () -> () = { }
    fileprivate var TableDidDisappearCompletion: () -> () = { }
    
    func setupUI () {
        let size = self.frame.height
        self.rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        self.rightViewMode = .always
        let arrowContainerView = UIView(frame: self.rightView!.frame)
        self.rightView?.addSubview(arrowContainerView)
        let center = arrowContainerView.center
        //arrow = Arrow(origin: CGPoint(x: center.x - arrowSize/2,y: center.y - arrowSize/2),size: arrowSize)
        let arrowImageView = UIImageView(frame: CGRect(x: center.x - arrowSize/2, y: center.y - arrowSize/2, width: arrowSize, height: arrowSize))
        arrowImageView.image = UIImage(named: "chevron-down")
        arrowImageView.contentMode = .scaleAspectFit
        arrowContainerView.addSubview(arrowImageView)
        
        self.backgroundView = UIView(frame: .zero)
        self.backgroundView.backgroundColor = .clear
        addTouchActionGesture()
        if isSearchEnable && handleKeyboard{
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.keyboardIsShown = true
        if self.isFirstResponder{
            if !self.isSelected{
                if !self.isShowKeyboard{
                    superview?.endEditing(true)
                }
                self.showList()
            }
        }
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.keyboardIsShown = false
        if self.isFirstResponder{
            self.keyboardHeight = 0
        }
        if(isSelected) {
            relocateList()
        }
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addTouchActionGesture() {
        
        let touchActionGesture =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
        if isSearchEnable{
            self.rightView?.addGestureRecognizer(touchActionGesture)
        }else{
            self.addGestureRecognizer(touchActionGesture)
        }
        self.backgroundView.addGestureRecognizer(touchActionGesture)
    }
    
    func getConvertedPoint(_ targetView: UIView, baseView: UIView?)->CGPoint{
        
        var point = targetView.frame.origin
        if nil == targetView.superview{
            return point
        }
        var superView = targetView.superview
        while superView != baseView{
            point = superView!.convert(point, to: superView!.superview)
            if nil == superView!.superview{
                break
            }else{
                superView = superView!.superview
            }
        }
        return superView!.convert(point, to: baseView)
    }
    
    func relocateList() {
        let height = (parentController?.view.frame.height ?? 0) - (pointToParent.y + self.frame.height + 5)
        var y = pointToParent.y + self.frame.height + 5
        
        if height < (keyboardHeight + tableheightX) {
            y = pointToParent.y - tableheightX
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
            self.table.frame = CGRect(x: self.pointToParent.x,
                                      y: y,
                                      width: self.frame.width,
                                      height: self.tableheightX)
            self.shadow.frame = self.table.frame
            self.shadow.dropShadow()
        },
                       completion: { (finish) -> Void in
            self.layoutIfNeeded()
        })
    }
    
    public func showList() {
        
        if parentController == nil{
            parentController = self.parentViewController
        }
        
        self.placeholder = self.clickedPlaceholder
        backgroundView.frame = parentController?.view.frame ?? backgroundView.frame
        pointToParent = getConvertedPoint(self, baseView: parentController?.view)
        parentController?.view.insertSubview(backgroundView, aboveSubview: self)
        TableWillAppearCompletion()
        if listHeight > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = listHeight
        }
        table = UITableView(frame: CGRect(x: pointToParent.x ,
                                          y: pointToParent.y + self.frame.height ,
                                          width: self.frame.width,
                                          height: self.frame.height))
        shadow = UIView(frame: table.frame)
        shadow.backgroundColor = .clear
        
        table.dataSource = self
        table.delegate = self
        table.alpha = 0
        table.separatorStyle = separatorStyle
        table.separatorInset = .zero
        table.layer.cornerRadius = 8
        table.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        table.widthBorder = 1
        table.colorBorder = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        table.backgroundColor = rowBackgroundColor
        table.rowHeight = rowHeight
        parentController?.view.addSubview(shadow)
        parentController?.view.addSubview(table)
        self.isSelected = true
        let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
        var y = self.pointToParent.y+self.frame.height+5
        if height < (keyboardHeight+tableheightX){
            y = self.pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        
                        self.table.frame = CGRect(x: self.pointToParent.x,
                                                  y: y,
                                                  width: self.frame.width,
                                                  height: self.tableheightX)
                        self.table.alpha = 1
                        self.shadow.frame = self.table.frame
                        self.shadow.dropShadow()
                        //self.arrow.position = .down
                        //self.arrow.isHidden = true
                        
                        
                       },
                       completion: { (finish) -> Void in
                        self.layoutIfNeeded()
                        
                       })
        
    }
    
    public func hideList() {
        print(self.keyboardIsShown)
        self.placeholder = self.hideListPlaceholder
        if(self.keyboardIsShown) {
            superview?.endEditing(true)
        } else {
            TableWillDisappearCompletion()
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: { () -> Void in
                            self.table.frame = CGRect(x: self.pointToParent.x,
                                                      y: self.pointToParent.y+self.frame.height,
                                                      width: self.frame.width,
                                                      height: 0)
                            self.shadow.alpha = 0
                            self.shadow.frame = self.table.frame
//                            self.arrow.position = .down
//                            self.arrow.isHidden = false
                           },
                           completion: { (didFinish) -> Void in
                            
                            self.shadow.removeFromSuperview()
                            self.table.removeFromSuperview()
                            self.backgroundView.removeFromSuperview()
                            self.isSelected = false
                            self.TableDidDisappearCompletion()
                           })
        }
    }
    
    @objc public func touchAction() {
        isSelected ?  hideList() : showList()
    }
    
    func reSizeTable() {
        if listHeight > rowHeight * CGFloat( dataArray.count) {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }else{
            self.tableheightX = listHeight
        }
        let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
        var y = self.pointToParent.y+self.frame.height+5
        if height < (keyboardHeight+tableheightX){
            y = self.pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        self.table.frame = CGRect(x: self.pointToParent.x,
                                                  y: y,
                                                  width: self.frame.width,
                                                  height: self.tableheightX)
                        self.shadow.frame = self.table.frame
                        self.shadow.dropShadow()
                        
                       },
                       completion: { (didFinish) -> Void in
                        //  self.shadow.layer.shadowPath = UIBezierPath(rect: self.table.bounds).cgPath
                        self.layoutIfNeeded()
                        
                       })
    }
    
    //MARK: Actions Methods
    public func didSelect(completion: @escaping (_ selectedText: String, _ index: Int , _ id:Int ) -> ()) {
        didSelectCompletion = completion
    }
    
    public func listWillAppear(completion: @escaping () -> ()) {
        TableWillAppearCompletion = completion
    }
    
    public func listDidAppear(completion: @escaping () -> ()) {
        TableDidAppearCompletion = completion
    }
    
    public func listWillDisappear(completion: @escaping () -> ()) {
        TableWillDisappearCompletion = completion
    }
    
    public func listDidDisappear(completion: @escaping () -> ()) {
        TableDidDisappearCompletion = completion
    }
    
}

//MARK: UITextFieldDelegate
extension DropDown: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        superview?.endEditing(true)
        return false
    }
    
    public func  textFieldDidBeginEditing(_ textField: UITextField) {
        self.dataArray = self.optionArray
        touchAction()
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.isAutoClear {
            textField.text = ""
        }
        self.selectedIndex = nil
        return isSearchEnable
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string != "" {
            self.searchText = self.text! + string
        }else{
            let subText = self.text?.dropLast()
            self.searchText = String(subText!)
        }
        if !isSelected {
            showList()
        }
        return true;
    }
    
}

///MARK: UITableViewDataSource
extension DropDown: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DropDownCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if indexPath.row != selectedIndex{
            cell!.backgroundColor = rowBackgroundColor
        }else {
            cell?.backgroundColor = selectedRowColor
        }
        
        if self.imageArray.count > indexPath.row {
            cell!.imageView!.image = UIImage(named: imageArray[indexPath.row])
        }
        cell!.textLabel!.numberOfLines = self.numberLineOfRow
        cell!.textLabel!.text = "\(dataArray[indexPath.row])"
        cell!.accessoryType = (indexPath.row == selectedIndex) && checkMarkEnabled  ? .checkmark : .none
        cell!.selectionStyle = .none
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.75)
        cell?.textLabel?.textAlignment = self.textAlignment
        return cell!
    }
}

//MARK: UITableViewDelegate
extension DropDown: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
        let selectedText = self.dataArray[self.selectedIndex!]
        tableView.cellForRow(at: indexPath)?.alpha = 0
        UIView.animate(withDuration: 0.1,
                       animations: { () -> Void in
                        tableView.cellForRow(at: indexPath)?.alpha = 1.0
                        tableView.cellForRow(at: indexPath)?.backgroundColor = self.selectedRowColor
                       } ,
                       completion: { (didFinish) -> Void in
                        self.text = "\(selectedText)"
                        
                        tableView.reloadData()
                       })
        if hideOptionsWhenSelect {
            touchAction()
            self.endEditing(true)
        }
        if let selected = optionArray.index(where: {$0 == selectedText}) {
            if let id = optionIds?[selected] {
                didSelectCompletion(selectedText, selected , id )
            }else{
                didSelectCompletion(selectedText, selected , 0)
            }
            
        }
        
    }
}

//MARK: Arrow
enum Position {
    case left
    case down
    case right
    case up
}

class Arrow: UIView {
    
    let shapeLayer = CAShapeLayer()
    var arrowColor:UIColor = .black {
        didSet {
            shapeLayer.fillColor = arrowColor.cgColor
        }
    }
    
    var position: Position = .down {
        didSet {
            switch position {
            case .left:
                self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                break
                
            case .down:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
                
            case .right:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
                
            case .up:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
            }
        }
    }
    
    init(origin: CGPoint, size: CGFloat ) {
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        // Get size
        let size = self.layer.frame.width
        
        // Create path
        let bezierPath = UIBezierPath()
        
        // Draw points
        let qSize = size/4
        
        bezierPath.move(to: CGPoint(x: 0, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size/2, y: qSize*3))
        bezierPath.addLine(to: CGPoint(x: 0, y: qSize))
        bezierPath.close()
        
        // Mask to path
        shapeLayer.path = bezierPath.cgPath
        
        if #available(iOS 12.0, *) {
            self.layer.addSublayer (shapeLayer)
        } else {
            self.layer.mask = shapeLayer
        }
    }
}

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.applySketchShadow(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.08), alpha: 1, x: 0, y: 6, blur: 10, spread: 0)
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

