//
//  GoalTableViewController.swift
//  FoodApp
//
//  Created by Timmy Nguyen on 3/31/24.
//

import UIKit

class GoalTableViewController: UITableViewController {
    
    let mealPlan: MealPlan
    var nutrientGoals: [NutrientID: Float]
    
    enum Section: CaseIterable {
        static var allCases: [Section] =
            [.nutrients(NutrientID.mainNutrients), .vitamins(NutrientID.vitamins), .minerals(NutrientID.minerals) ]
        
        case nutrients([NutrientID]), vitamins([NutrientID]), minerals([NutrientID])
    }
    
    init(mealPlan: MealPlan, nutrientGoals: [NutrientID : Float]) {
        self.mealPlan = mealPlan
        self.nutrientGoals = nutrientGoals
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(NutritionTableViewCell.self, forCellReuseIdentifier: NutritionTableViewCell.reuseIdentifier)
        title = "My Goals"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .edit, primaryAction: didTapEditButton())
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        switch section {
        case .nutrients(let nutrients):
            return nutrients.count
        case .vitamins(let vitamins):
            return vitamins.count
        case .minerals(let minerals):
            return minerals.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NutritionTableViewCell.reuseIdentifier, for: indexPath) as! NutritionTableViewCell
        let section = Section.allCases[indexPath.section]
        let nutrientID: NutrientID
        switch section {
        case .nutrients(let nutrients):
            nutrientID = nutrients[indexPath.row]
        case .vitamins(let vitamins):
            nutrientID = vitamins[indexPath.row]
        case .minerals(let minerals):
            nutrientID = minerals[indexPath.row]
        }
        
        cell.update(nutrientID: nutrientID, nutrientAmount: mealPlan.getTotalNutrients(nutrientID), nutrientGoal: nutrientGoals[nutrientID] ?? 0)
//        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = Section.allCases[section]
        switch section {
        case .nutrients(_):
            return "Nutrients"
        case .vitamins(_):
            return "Vitamins"
        case .minerals(_):
            return "Minerals"
        }
    }

    func didTapEditButton() -> UIAction {
        return UIAction { [self] _ in
            let vc = UINavigationController(rootViewController: EditGoalTableViewController(nutrientGoals: nutrientGoals))
            present(vc, animated: true)
        }
    }

}
