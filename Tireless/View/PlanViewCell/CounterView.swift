//
//  CounterView.swift
//  Tireless
//
//  Created by Hao on 2022/4/21.
//

import Foundation
import UIKit

class CounterView: UIView {
    
    private var plusButton: CustomButton = {
        let button = CustomButton()
        button.setBackgroundImage(UIImage(named: "Icons_Add"), for: .normal)
        button.tintColor = .white
        button.touchEdgeInsets = UIEdgeInsets(top: -15, left: -10, bottom: -15, right: -10)
        return button
    }()
    
    private var minusButton: CustomButton = {
        let button = CustomButton()
        button.setBackgroundImage(UIImage(named: "Icons_Subtract"), for: .normal)
        button.tintColor = .white
        button.touchEdgeInsets = UIEdgeInsets(top: -15, left: -10, bottom: -15, right: -10)
        return button
    }()
    
    private var inputTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.font = .bold(size: 20)
        textField.text = "1"
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        buttonConstraints()
        textFieldConstraints()
        self.backgroundColor = .themeBGSecond
        self.layer.cornerRadius = 15
        minusButton.addTarget(self, action: #selector(minusButtonTap), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusButtonTap), for: .touchUpInside)
        inputTextField.delegate = self
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 1
    }
    
    @objc func minusButtonTap() {
        guard let text = inputTextField.text,
              let amount = Int(text)
        else { return }

        inputTextField.text = String(amount - 1)
        checkData()
    }
    
    @objc func plusButtonTap() {
        guard let text = inputTextField.text,
              let amount = Int(text)
        else { return }

        inputTextField.text = String(amount + 1)
        checkData()
    }
    
    private func checkData() {
        if inputTextField.text == "1" {
            disable(item: minusButton)
        } else {
            enable(item: minusButton)
        }
        if inputTextField.text == "99" {
            disable(item: plusButton)
        } else {
            enable(item: plusButton)
        }
        guard let text = inputTextField.text,
              let amount = Int(text)
        else { return }
        if amount > 99 {
            inputTextField.text = String(99)
        }
    }
    
    private func disable(item: UIControl) {

        item.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

        item.tintColor = UIColor.white.withAlphaComponent(0.4)

        item.isEnabled = false
    }

    private func enable(item: UIControl) {

        item.layer.borderColor = UIColor.white.cgColor

        item.tintColor = UIColor.white

        item.isEnabled = true
    }
    
    func setInputField(_ num: Int) {
        inputTextField.text = "\(num)"
    }
    
    func getInputField() -> String {
        return inputTextField.text ?? ""
    }
    
    private func buttonConstraints() {
        addSubview(minusButton)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            minusButton.heightAnchor.constraint(equalToConstant: 15),
            minusButton.widthAnchor.constraint(equalToConstant: 15)
        ])
        
        addSubview(plusButton)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            plusButton.heightAnchor.constraint(equalToConstant: 15),
            plusButton.widthAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    private func textFieldConstraints() {
        
        addSubview(inputTextField)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 18),
            inputTextField.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -18),
            inputTextField.heightAnchor.constraint(equalTo: plusButton.heightAnchor, constant: 25),
            inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension CounterView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
         checkData()
    }
}
