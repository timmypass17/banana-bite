//
//  SearchFoodTableViewController.swift
//  FoodApp
//
//  Created by Timmy Nguyen on 3/1/24.
//

import UIKit
import VisionKit

class SearchFoodTableViewController: UITableViewController {

    var history: [CDFood] = []
    
    var searchController: UISearchController!
    private var resultsTableController: ResultsTableViewController!
    
    var meal: Meal?
    let foodService: FoodService
    var searchTask: Task<Void, Never>? = nil
    var debounceTimer: Timer?
    
    weak var delegate: FoodDetailTableViewControllerDelegate?
    
    var scannerAvailable: Bool {
        DataScannerViewController.isSupported &&
        DataScannerViewController.isAvailable
    }
    
    init(foodService: FoodService, meal: Meal? = nil) {
        self.history = CoreDataStack.shared.getFoodHistory()
        self.foodService = foodService
        self.meal = meal
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.reuseIdentifier)
        if let meal, let meals = meal.mealPlan?.meals {
            let titleView = SearchTitleView(selectedMeal: meal, meals: meals)
            titleView.delegate = self
            navigationItem.titleView = titleView
        }

        resultsTableController = ResultsTableViewController(meal: meal, foodService: foodService)
        resultsTableController.delegate = delegate
        resultsTableController.historyDelegate = self
        searchController = UISearchController(searchResultsController: resultsTableController)
//        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        
        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "barcode.viewfinder"), primaryAction: didTapBarcodeButton())
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.reuseIdentifier, for: indexPath) as! HistoryTableViewCell
        cell.delegate = self
        let food = history[indexPath.row]
        cell.update(with: food)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let food = history[indexPath.row]
        let detailVC = FoodDetailTableViewController(food: food.convertToFDCFood(), meal: meal, foodService: foodService)
        detailVC.delegate = delegate
        detailVC.historyDelegate = self
        present(UINavigationController(rootViewController: detailVC), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "History"
    }

    func didTapBarcodeButton() -> UIAction {
        return UIAction { [self] _ in
            guard scannerAvailable else { return }
            let viewController = DataScannerViewController(
                recognizedDataTypes: [.barcode()],
                qualityLevel: .accurate,
                recognizesMultipleItems: false,
                isHighFrameRateTrackingEnabled: false,
                isHighlightingEnabled: true)
            
            
            viewController.delegate = self
            try? viewController.startScanning()
            present(viewController, animated: true)

        }
    }
}


// MARK: - UISearchBarDelegate

extension SearchFoodTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task {
            do {
                let foods: [Food] = try await foodService.getFoods(query: searchBar.text!)
                resultsTableController.foods = foods
                resultsTableController.tableView.reloadData()
            } catch {
                print("\(#function) \(error)")
            }
        }
        searchBar.resignFirstResponder()
    }
    
}

extension SearchFoodTableViewController: SearchTitleViewDelegate {
    func searchTitleView(_ sender: SearchTitleView, didSelectMeal meal: Meal) {
        self.meal = meal
    }
}

extension SearchFoodTableViewController: FoodDetailTableViewControllerHistoryDelegate {
    func foodDetailTableViewController(_ tableViewController: FoodDetailTableViewController, didUpdateHistoryWithFood food: CDFood) {
        if !history.contains(food) {
            history.append(food)
        }
        history = history.sorted { $0.updatedAt > $1.updatedAt }
        tableView.reloadData()
    }
}

extension SearchFoodTableViewController: HistoryTableViewCellDelegate {
    func historyTableViewCell(_ cell: HistoryTableViewCell, didDeleteFood food: CDFood) {
        guard let row = history.firstIndex(where: { $0 == food }) else { return }
        history.remove(at: row)
        let indexPath = IndexPath(row: row, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension SearchFoodTableViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
        // Implement this delegate method to disable or remove the data-scanning controls in your interface.
        // For example, the scanner calls this method when users tap Don’t Allow the first time the system prompt appears, as described in Provide a reason for using the camera.
        navigationItem.rightBarButtonItem?.isEnabled = scannerAvailable
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        guard let item = addedItems.first else { return }
        
        if case .barcode(let barcode) = item {
            Task {
                guard let barcodeID = barcode.payloadStringValue,
                      let food = try? await foodService.getFoods(query: barcodeID).first
                else {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    dismiss(animated: true)
                    showFoodNotFoundAlert()
                    return
                }
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                let foodDetailViewController = FoodDetailTableViewController(food: food, meal: meal, foodService: foodService)
                foodDetailViewController.delegate = delegate
                
                // Only 1 view controlelr can be presented at once. Dismiss the barcode scanning view
                dismiss(animated: true)
                present(UINavigationController(rootViewController: foodDetailViewController), animated: true)
            }
        }
    }
    
    func showFoodNotFoundAlert() {
        let alert = UIAlertController(title: "Item not found", message: "This item is not in the database.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
