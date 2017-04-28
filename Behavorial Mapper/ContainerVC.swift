//
//  MappingContainerVC.swift
//  Behavorial Mapper
//
//  Created by Alexander on 15/04/2017.
//  Copyright © 2017 Alexander. All rights reserved.
//

import UIKit
import QuartzCore

enum VCType {
    case start
    case createProject
    case mapping
}

protocol ContainerVCDelegate {
    func projectFromTemplate(ofProject: Project)
}

class ContainerVC: UIViewController {

   /* OLD: Only used for MappingVC
     
    var mappingVC: MappingVC!
    var menuVC: MappingMenuVC?
    
    var menuShowing = false
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mappingVC = UIStoryboard.mappingVC()
        mappingVC.delegate = self
        mappingVC.project = project!
        
        view.insertSubview(mappingVC.view, at: 1)
    } */

    // NEW: Loads StartVC
    
    
    
    var startVC: StartVC?
    var createProjectVC: CreateProjectVC?
    var mappingVC: MappingVC?
    var menuVC: MappingMenuVC?

    var project: Project?
    
    // To avoid errors
    var menuShowing = false
    var currentVC: VCType = .start
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startVC = UIStoryboard.startVC()
        startVC?.delegate = self
        
        view.insertSubview(startVC!.view, at: 1)
    }
    
    func loadVC(ofType: VCType) {
        if (ofType == .start) {
            if (startVC == nil) {
                startVC = UIStoryboard.startVC()
                startVC?.delegate = self
            }
        }
        if (ofType == .createProject) {
            if (createProjectVC == nil) {
                createProjectVC = UIStoryboard.createProjectVC()
                createProjectVC?.delegate = self
            }
        }
        if (ofType == .mapping) {
            if (mappingVC == nil) {
                mappingVC = UIStoryboard.mappingVC()
                mappingVC?.delegate = self
            }
        }
    }
    
    func presentVC(ofType: VCType) {
        switch ofType {
        case .start:
            view.addSubview(startVC!.view)
        case .createProject:
            view.addSubview(createProjectVC!.view)
        case .mapping:
            view.addSubview(mappingVC!.view)
        }
        deloadVC()
        currentVC = ofType
        print("CurrentVC: \(ofType)")
    }
    
    func deloadVC() {
        switch currentVC {
        case .start:
            self.startVC!.view.removeFromSuperview()
            self.startVC = nil
        case .mapping:
            self.mappingVC!.view.removeFromSuperview()
            self.mappingVC = nil
        case .createProject:
            self.createProjectVC!.view.removeFromSuperview()
            self.createProjectVC = nil
        }
    }
}

extension ContainerVC: StartVCDelegate {
    func loadProject(fromProject: Project) {
        loadVC(ofType: .mapping)
        mappingVC?.project = fromProject
        presentVC(ofType: .mapping)
    }

    func createNewProject() {
        loadVC(ofType: .createProject)
        presentVC(ofType: .createProject)
    }
    
    func loadFromTemplate(fromProject: Project) {
        loadVC(ofType: .createProject)
        createProjectVC?.projectFromTemplate(ofProject: fromProject)
        presentVC(ofType: .createProject)
    }
}

extension ContainerVC: CreateProjectVCDelegate {
    
    func createProject(project: Project) {
        mappingVC = UIStoryboard.mappingVC()
        mappingVC?.delegate = self
        mappingVC?.project = project
        view.addSubview(mappingVC!.view)
        deloadVC()
        currentVC = .mapping
        print("createProjectDelegate: createProject")
    }
    
    func cancelCreateProject() {
        loadVC(ofType: .start)
        presentVC(ofType: .start)
    }
    
}

extension ContainerVC: MappingVCDelegate {
    
    func toggleMenu() {
        if (!menuShowing) {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    func animateMainViewXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.mappingVC?.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func showMenu() {
        if (menuVC == nil) {
            menuVC = UIStoryboard.mappingMenuVC()
            menuVC?.mappingDelegate = mappingVC
            menuVC?.containerDelegate = self
        }
        view.insertSubview(menuVC!.view, at: 0)
        
        addChildViewController(menuVC!)
        menuVC?.didMove(toParentViewController: self)
        
        menuShowing = true
        mappingVC!.view.layer.shadowOpacity = 0.8
        animateMainViewXPosition(targetPosition: MENU_EXPAND_OFFSET)
    }
    
    func hideMenu() {
        menuShowing = false
        animateMainViewXPosition(targetPosition: 0) { finished in
            self.mappingVC!.view.layer.shadowOpacity = 0.0
            self.menuVC!.view.removeFromSuperview()
            self.menuVC = nil
        }
    }
    
    func killMenu() {
        menuShowing = false
        menuVC!.view.removeFromSuperview()
        menuVC = nil
    }
}

extension ContainerVC: MenuContainerDelegate {
    func closeMenu() {
        hideMenu()
    }
    
    func exitProject() {
        killMenu()
        loadVC(ofType: .start)
        presentVC(ofType: .start)
    }
}
