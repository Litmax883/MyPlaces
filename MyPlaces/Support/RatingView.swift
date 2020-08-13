////
////  RatingView.swift
////  MyPlaces
////
////  Created by MAC on 05.08.2020.
////  Copyright © 2020 Litmax. All rights reserved.
////
//
//import UIKit
//
//@IBDesignable class RatingView: UIStackView {
//    
//    // MARK: Properties
//    
//    private var ratingButtons = [UIButton]()
//    
//    var rating = 0 {
//        didSet {
//            updateButtonSelectionState()
//        }
//    }
//    
//    @IBInspectable var starSize: CGSize = CGSize(width: 44, height: 44) {
//        didSet {
//            setupButtons()
//        }
//    }
//    
//    @IBInspectable var starCount: Int = 5 {
//        didSet {
//            setupButtons()
//        }
//    }
//
//    // MARK: Init
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupButtons()
//    }
//    
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//        setupButtons()
//    }
//    // MARK: Button action
//    
//    @objc func ratingButtonTapped(button: UIButton) {
//        
//        guard let index = ratingButtons.firstIndex(of: button) else { return }
//        
//        // Calculate the rating
//        let selectedRating = index + 1
//        
//        if selectedRating == rating {
//            rating = 0
//        } else {
//            rating = selectedRating
//        }
//        
//    }
//    
//    // MARK: Private Methods
//    
//    private func setupButtons() {
//        
//        for button in ratingButtons {
//            removeArrangedSubview(button)
//            button.removeFromSuperview()
//        }
//        
//        ratingButtons.removeAll()
//        
//        // Load button image
//        
//        let filledStar = UIImage.init(systemName: "star.fill")
//        let emptyStar = UIImage.init(systemName: "star")
//        let highlightedStar = UIImage.init(systemName: "star.lefthalf.fill")
//        
//        for _ in 0..<starCount {
//            
//            // Create the buttons
//            let button = UIButton()
//            
//            // Set the button Images
//            
//            button.setImage(emptyStar, for: .normal)
//            button.setImage(filledStar, for: .selected)
//            button.setImage(highlightedStar, for: .highlighted)
//            button.setImage(highlightedStar, for: [.highlighted, .selected])
//            
//            // Add consctrains
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
//            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
//            
//            // SetUp the button action
//            button.addTarget(self, action: #selector(ratingButtonTapped(button:)) , for: .touchUpInside)
//            
//            // Add the button to the stack
//            addArrangedSubview(button)
//            
//            // Add the new button on the rating button array
//            ratingButtons.append(button)
//        }
//        updateButtonSelectionState()
//    }
//    
//    private func updateButtonSelectionState () {
//        for (index, button) in ratingButtons.enumerated() {
//            button.isSelected = index < rating
//        }
//    }
//    
//}
