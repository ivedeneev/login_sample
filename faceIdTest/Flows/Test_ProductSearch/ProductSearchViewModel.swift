//
//  ProductSearchViewModel.swift
//  faceIdTest
//
//  Created by Igor Vedeneev on 20.08.2021.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxCocoa

protocol ProductSearchViewModel {
    
    // input
    var sortingTerm: AnyObserver<SortingTerm> { get }
    var filterTerm: AnyObserver<Filter> { get }
    var searchQuery: AnyObserver<String> { get }
    
    var showSort: AnyObserver<Void> { get }
    var showFilter: AnyObserver<Void> { get }
    
    var loadNextPage: AnyObserver<Void> { get }
    var refresh: AnyObserver<Void> { get }
    //favorites?
    
    // output
    var didShowSort: Observable<Void> { get }
    var didShowFilter: Observable<Void> { get }
    
    var products: Driver<[Product]> { get }
    var isLoading: Driver<Bool> { get }
    
    var selectedSortingTerm: Driver<SortingTerm> { get }
    var selectedFilterTerm: Driver<Filter> { get }
}

final class ProductSearchViewModelImpl: ProductSearchViewModel {
    
    var sortingTerm: AnyObserver<SortingTerm>
    var filterTerm: AnyObserver<Filter>
    var searchQuery: AnyObserver<String>
    
    var loadNextPage: AnyObserver<Void>
    var refresh: AnyObserver<Void>
    
    var showSort: AnyObserver<Void>
    var showFilter: AnyObserver<Void>
    var didShowSort: Observable<Void>
    var didShowFilter: Observable<Void>
    
    var selectedSortingTerm: Driver<SortingTerm>
    var selectedFilterTerm: Driver<Filter>
    
    var isLoading: Driver<Bool> = .empty()
    
    private let _products = BehaviorRelay<[Product]>(value: [])
    lazy var products: Driver<[Product]> = _products.asDriver()
    
    private let disposeBag = DisposeBag()
    
    
    init(
        scheduler: SchedulerType = MainScheduler.instance,
        service: ProductService = .init()
    ){
        let _showSortSubject = PublishSubject<Void>()
        showSort = _showSortSubject.asObserver()
        didShowSort = _showSortSubject.asObservable()
        
        let _showFilterSubject = PublishSubject<Void>()
        showFilter = _showFilterSubject.asObserver()
        didShowFilter = _showFilterSubject.asObservable()
        
        let _sortSubject = PublishSubject<SortingTerm>()
        sortingTerm = _sortSubject.asObserver()
        selectedSortingTerm = _sortSubject
            .startWith(.up) // default value
            .asDriver(onErrorJustReturn: .up)
        
        let _filterSubject = PublishSubject<Filter>()
        filterTerm = _filterSubject.asObserver()
        selectedFilterTerm = _filterSubject
            .startWith(.none) // default value
            .asDriver(onErrorJustReturn: .none)
        
        let _search = PublishSubject<String>()
        searchQuery = _search.asObserver()
        
        let query = _search.distinctUntilChanged().debounce(.milliseconds(500), scheduler: scheduler).share()
        
        let _nextPage = PublishSubject<Void>()
        loadNextPage = _nextPage.asObserver()
        
        let _refresh = PublishSubject<Void>()
        refresh = _refresh.asObserver()
        
        let newRequests = Observable.combineLatest(selectedSortingTerm.asObservable(), selectedFilterTerm.asObservable(), query)
            .map { (sort, filter, query) -> ProductRequest in
                let request = ProductRequest()
                request.sort = sort
                request.filter = filter
                request.query = query
                return request
            }
            .share()
        
        newRequests.mapTo([]).bind(to: _products).disposed(by: disposeBag)
        
        let offset = _nextPage.asObservable().withLatestFrom(products).map { $0.count }
        let nextPages = offset.withLatestFrom(newRequests) { offset, request -> ProductRequest in
            request.offset = offset
            return request
        }
        
        let refresh = _refresh.withLatestFrom(newRequests)
        
        let allSearchResults = Observable.merge(newRequests, nextPages, refresh).share()
        let searchEvents = allSearchResults.flatMapLatest(service.loadProducts).materialize().share()
        
        searchEvents.elements().bind(to: _products).disposed(by: disposeBag)
    }
}

final class ProductRequest {
    var query: String!
    var offset: Int = 0
    var limit = 20
    var sort: SortingTerm = .up
    var filter: Filter = .none
}

final class ProductService {
    func loadProducts(request: ProductRequest) -> Observable<[Product]> {
        var numbers = Array(0..<request.offset + request.limit)
        
        switch request.filter {
        case .even:
            numbers = numbers.filter { $0 % 2 == 0 }
        case .odd:
        numbers = numbers.filter { $0 % 2 != 0 }
        default:
            break
        }
        
        if request.sort == .down {
            numbers = numbers.reversed()
        }
        
        return .just(numbers.map(Product.init))
    }
}
