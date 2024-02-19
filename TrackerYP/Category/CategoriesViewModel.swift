import Foundation

protocol CategoriesViewModelDelegate: AnyObject {
    func didUpdateCategories()
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoriesViewModel {
    // MARK: - Public properties
    weak var delegate: CategoriesViewModelDelegate?
    
    // MARK: - Private properties
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            delegate?.didUpdateCategories()
        }
    }
    
    private(set) var selectedCategory: TrackerCategory? = nil {
        didSet {
            guard let selectedCategory else { return }
            delegate?.didSelectCategory(selectedCategory)
        }
    }
    
    // MARK: - Lifecycle
    init(selectedCategory: TrackerCategory?) {
        self.selectedCategory = selectedCategory
        trackerCategoryStore.delegate = self
    }
    
    // MARK: - Public
    func loadCategories() {
        categories = getCategoriesFromStore()
    }
    
    func selectCategory(at indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
    }
    
    func handleCategoryFormConfirm(data: TrackerCategory.Data) {
        if categories.contains(where: { $0.id == data.id }) {
            try? updateCategory(with: data)
        } else {
            try? addCategory(with: data.label)
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        do {
            try trackerCategoryStore.deleteCategory(category)
            loadCategories()
            if category == selectedCategory {
                selectedCategory = nil
            }
        } catch {
            throw CategoriesErrors.deleteError
        }
    }
    
    // MARK: - Private
    private func getCategoriesFromStore() -> [TrackerCategory] {
        do {
            let categories = try trackerCategoryStore.categoriesCoreData.map {
                try trackerCategoryStore.makeCategory(from: $0)
            }
            return categories
        } catch {
            return []
        }
    }
    
    private func addCategory(with label: String) throws {
        do {
            try trackerCategoryStore.makeCategory(with: label)
            loadCategories()
        } catch {
            throw CategoriesErrors.addCategoryError
        }
    }
    
    private func updateCategory(with data: TrackerCategory.Data) throws {
        do {
            try trackerCategoryStore.updateCategory(with: data)
            loadCategories()
        } catch {
            throw CategoriesErrors.updateCategoryError
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        categories = getCategoriesFromStore()
    }
    
    func didFailWithError(_ error: Error) {
        // Обрабатываем ошибку
        print("Error occurred: \(error.localizedDescription)")
    }
}
