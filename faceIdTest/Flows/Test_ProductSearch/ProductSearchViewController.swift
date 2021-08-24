//
//  ProductSearchViewController.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 20.08.2021.
//

import UIKit
import RxSwift
import RxSwiftExt
import RxCocoa
import IVCollectionKit

final class ProductSearchViewController: CollectionViewController {
    var viewModel: ProductSearchViewModel!
    let toolbar = UIToolbar()
    let filter = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: nil)
    let sppace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let sort = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: nil)
    
    let searchBar = UISearchBar()
    let refreshControl = UIRefreshControl()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(toolbar)
        
        toolbar.setItems([filter, sppace, sort], animated: false)
        view.addSubview(toolbar)
        
        collectionView.constraints.first(where: { $0.firstAttribute == .top })?.constant = 44
        navigationItem.titleView = searchBar
        searchBar.placeholder = "Название, цвет, артикул"
        
        collectionView.refreshControl = refreshControl
    
        
        bind()
    }
    
    func bind() {
        assert(viewModel != nil)
        
        filter.rx.tap.bind(to: viewModel.showFilter).disposed(by: disposeBag)
        sort.rx.tap.bind(to: viewModel.showSort).disposed(by: disposeBag)
        searchBar.rx.text.orEmpty.bind(to: viewModel.searchQuery).disposed(by: disposeBag)
        
        collectionView.rx.reachedBottom()
            .bind(to: viewModel.loadNextPage)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .startWith()
            .bind(to: viewModel.refresh)
            .disposed(by: disposeBag)
        
        viewModel.products
            .mapTo(false)
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.products
            .drive(rx.products)
            .disposed(by: disposeBag)
        
        viewModel.selectedFilterTerm
            .map { $0.description }
            .drive(filter.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.selectedSortingTerm
            .map { $0.description }
            .drive(sort.rx.title)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        toolbar.frame = CGRect(x: 0, y: navigationController!.navigationBar.frame.maxY, width: view.bounds.width, height: 44)
        collectionView.frame = CGRect(x: 0, y: toolbar.frame.maxY, width: view.bounds.width, height: view.bounds.height - toolbar.frame.maxY)
    }
}

extension Reactive where Base: ProductSearchViewController {
    var products: Binder<[Product]> {
        Binder(base) { (vc, products) in
            let section = CollectionSection(id: "products", items: [])
            section += products.map { p in
                CollectionItem<CommonCell>(item: .init(title: p.title.description, subtitle: nil, icon: nil))
            }
            
            vc.director.sections = [section]
            vc.director.performUpdates()
        }
    }
}



final class ProductSearchCoordinator: BaseCoordinator<Void> {
    
    weak var window: UIWindow?
    
    private let disposeBag = DisposeBag()
    
    init(_ window: UIWindow?) {
        super.init()
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let vc = ProductSearchViewController()
        let viewModel: ProductSearchViewModel = ProductSearchViewModelImpl()
        vc.viewModel = viewModel
        
        viewModel.didShowSort
            .mapTo(SortingTerm.allCases)
            .flatMapLatest(actionSheet)
            .bind(to: viewModel.sortingTerm)
            .disposed(by: disposeBag)
        
        viewModel.didShowFilter
            .mapTo(Filter.allCases)
            .flatMapLatest(actionSheet)
            .bind(to: viewModel.filterTerm)
            .disposed(by: disposeBag)
        
        rootViewController = UINavigationController(rootViewController: vc)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        return .never()
    }
    
    func actionSheet<T: CustomStringConvertible>(actions: [T]) -> Observable<T> {
        Observable.create { [rootViewController] observer in
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actions.forEach { (element) in
                ac.addAction(
                    .init(title: element.description, style: .default, handler: { _ in
                        observer.onNext(element)
                        observer.onCompleted()
                    }
                ))
            }
            
            ac.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            
            
            rootViewController?.present(ac, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
}


struct Product: Hashable {
    let title: Int
}

enum SortingTerm: CustomStringConvertible, CaseIterable {
    var description: String {
        switch self {
        case .up:
            return "From lowest price"
        default:
            return "From highest price"
        }
    }
    
    case up
    case down
}

enum Filter: CustomStringConvertible, CaseIterable {
    var description: String {
        switch self {
        case .odd:
            return "Only odd"
        case .even:
            return "Only even"
        default:
            return "None"
        }
    }
    
    
    case odd
    case even
    case none
}
