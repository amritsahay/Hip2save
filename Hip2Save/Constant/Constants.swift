//
//  Constants.swift
//  Hip2Save
//
//  Created by ip-d on 14/11/18.
//  Copyright © 2018 Hip Happenings. All rights reserved.
//

import UIKit

enum Identifiers:String
{
    case DealsTableViewCell                 = "DealsTableViewCell"
    case LoginViewController                = "LoginViewController"
    case RegisterViewController             = "RegisterViewController"
    case ForgotViewController               = "ForgotViewController"
    case DealsViewController                = "DealsViewController"
    case CustomTabBarViewController         = "CustomTabBarViewController"
    case SideMenuViewController             = "SideMenuViewController"
    case TipsViewController                 = "TipsViewController"
    case StoresViewControllers              = "StoresViewControllers"
    case Hip2ShareViewController            = "Hip2ShareViewController"
    case ShareYourDealViewController        = "ShareYourDealViewController"
    case ThankYouViewController             = "ThankYouViewController"
    case RestaurantViewController           = "RestaurantViewController"
    case MoreViewController                 = "MoreViewController"
    case BudgetViewController               = "BudgetViewController"
    case BudgetIdentifier                   = "budgetIdentifier"
    case AddEnvolopeIdentifier              = "addEnvolopeIdentifier"
    case ShowEnvelopeIdentifier             = "showEnvelopeIdentifier"
    case AddEnvelopeViewController          = "AddEnvelopeViewController"
    case AddTransactionIdentifier           = "addTransactionIdentifier"
    case DetailViewIdentifier               = "DetailViewIdentifier"
    case StorePostViewController            = "StorePostViewController"
    case CategoryViewController             = "CategoryViewController"
    case CategoryIdentifier                 = "CategoryIdentifier"
    case CategoryDetailIdentifier           = "CategoryDetailIdentifier"
    case CategoryDetailViewController       = "CategoryDetailViewController"
    case DIYNavigationIdentifier            = "DIYNavigationIdentifier"
    case DIYViewController                  = "DIYViewController"
    case DIYDetailViewController            = "DIYDetailViewController"
    case DIYDetailIdentifier                = "DIYDetailIdentifier"
    case CookBookIdentifer                  = "CookBookIdentifer"
    case CookDetailIdentifier               = "CookDetailIdentifier"
    case CookBookDetailViewController       = "CookBookDetailViewController"
    case MyCookBookIdentifer                = "MyCookBookIdentifer"
    case MyCookBookViewController           = "MyCookBookViewController"
    case CommentsViewController             = "CommentsViewController"
    case PostViewController                 = "PostViewController"
    case postCommentIdentifier              = "postCommentIdentifier"
    case commentsIdentifier                 = "commentsIdentifier"
    case SettingTableViewController         = "SettingTableViewController"
    case SettingNavigationController        = "SettingNavigationController"
    case ShowProfileIdentifier              = "showProfileIdentifier"
    case ProfileViewController              = "ProfileViewController"
    case ChangePasswordViewController       = "ChangePasswordViewController"
    case ChangePasswordNavigation           = "ChangePasswordNavigation"
    case RepliesViewController              = "RepliesViewController"
}

enum API:String
{
    case generate_auth_cookie               = "generate_auth_cookie"
    case hip_api                            = "hipapi"
    case hiplist_toggle                     = "hiplist_toggle"
    case register                           = "register"
    case store_list                         = "store_list"
    case category_list                      = "category_list"
    case diy_cat                            = "diy_cat"
    case recipes_cat                        = "recipes_cat"
    case social_login                       = "social_login"
    case mycookbook                         = "mycookbook"
    case cookbook_toggle                    = "cookbook_toggle"
    case add_hip2share                      = "add_hip2share"
    case hip2share_posts                    = "hip2share_posts"
    case get_comments                       = "get_comments"
    case add_comment                        = "add_comment"
    case user_profile                       = "user_profile"
    case update_user                        = "update_user"
    case change_password                    = "change_password"
    
}

enum Key:String {
    
    case username           =    "username"
    case password           =    "password"
    case top_four           =    "header_posts"
    case option             =    "option"
    case posts_per_page     =    "posts_per_page"
    case current_page       =    "current_page"
    case get_posts          =    "get_posts"
    case ID                 =    "ID"
    case post_title         =    "post_title"
    case post_date          =    "post_date"
    case comment_count      =    "comment_count"
    case thumbnail_image    =    "thumbnail_image"
    case link               =    "link"
    case post_flag          =    "post_flag"
    case post_flag_url      =    "post_flag_url"
    case hiplist            =    "hiplist"
    case post_content       =    "post_content"
    case post_id            =    "post_id"
    case user_id            =    "user_id"
    case cookie             =    "cookie"
    case action             =    "action"
    case deal_search        =    "deal_search"
    case keyword            =    "keyword"
    case myhiplist          =    "myhiplist"
    case display_name       =    "display_name"
    case email              =    "email"
    case store_id           =    "store_id"
    case deal_type          =    "deal_type"
    case restaurant         =    "restaurant"
    case category_id        =    "category_id"
    case recipes            =    "recipes"
    case recipes_catid      =    "recipes_catid"
    case uid                =    "uid"
    case provider           =    "provider"
    case googleplus         =    "googleplus"
    case facebook           =    "facebook"
    case store              =    "store"
    case featured_image     =    "featured_image"
    case deal_link          =    "deal_link"
    case comments_per_page  =  "comments_per_page"
    case comment_parent     = "comment_parent"
    case content            = "content"
    case comment_parent_id  = "comment_parent_id"
    case shipping_info      = "shipping_info"
}

class Constants: NSObject {
    // REST STATUS CODE
    static let  OK                      = 200
    static let  Created                 = 201
    static let  Accepted                = 202
    static let  Bad_Request             = 400
    static let  Unauthorized            = 401
    static let  Payment_Required        = 402
    static let  Forbidden               = 403
    static let  Not_Found               = 404
    static let  Internal_Server_Error   = 500
    static let  Not_Implemented         = 501
    
    static let selectedColor:UIColor = UIColor.init(red: 1.0, green: 0.553, blue: 0.040, alpha: 1.0)
    static let headerColor:UIColor = UIColor.init(red: 0.043, green: 0.204, blue: 0.310, alpha: 1.0)
    
   
    //static let baseURL = "https://vipankumar.in/hip2save/wp-content/themes/hip2save/hipapi2.php"
    // static let baseURL = "https://hip2save-com-develop.go-vip.co/wp-content/themes/hip2save/hipapi.php"
    static let baseURL = "https://hip2save.com/wp-content/themes/hip2save/hipapi.php"
    static let notifyDealCellDidChange = Notification.Name("notifyDealCellDidChange")
    static let notifyUserDidChange = Notification.Name("notifyUserDidChange")
}

// 680163960624-cfb8r6f7o0negme9r3j4apps5glca7br.apps.googleusercontent.com
struct UserDefaultsKeys {
    static let APP_OPENED_COUNT = "APP_OPENED_COUNT"
}
