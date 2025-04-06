//
//  Constants.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-05.
//

import Foundation
import UIKit

// MARK: - Constants

struct Constants {
    
    
    struct Padding {
        static let globalPadding: CGFloat = 48.0
        static let globalLeadingPadding: CGFloat = 24.0
        static let globalTrailingPadding: CGFloat = -24.0
        static let globalTopPadding: CGFloat = 24.0
        static let globalBottomPadding: CGFloat = -24.0


    }
        
    struct CornerRaduce {
        static var cardRaduce: CGFloat {
            return 16.0
        }
        
        static var imageRaduce: CGFloat {
            return 16.0
        }
        
        static var buttonRaduce: CGFloat {
            return 16.0
        }
        
        static var generalRaduce: CGFloat {
            return 16.0
        }
    }
    
    struct Border {
        
        static var generalBorderWidth: CGFloat {
            return 1.0
        }
    }
    
    struct Shadow {
        static var shadowOpacity: Float {
            return 0.1
        }
        
        static var tabbarShadowOpacity: Float {
            return 0.25
        }
        
        static var buttonShadowOpacity: Float {
            return 0.25
        }
        
        static var shadowRadius: CGFloat {
            return 4.0
        }
        
        static var buttonShadowRadius: CGFloat {
            return 24.0
        }
        
        static var shadowOffset: CGSize {
            CGSize(width: 0, height: 0)
        }
        
        static var shadowColor: CGColor {
            return  UIColor.label.cgColor
        }
    }


    
}
