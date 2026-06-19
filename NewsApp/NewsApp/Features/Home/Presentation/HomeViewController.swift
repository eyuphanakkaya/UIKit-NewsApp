//
//  ViewController.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    private var tableView: UITableView!
    
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.load()
            await viewModel.fetchReadingList()
        }
    }
}

private extension HomeViewController {
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupBindings() {
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func didSelectNews(_ selectedNews: NewsModel) {
        let vc = DetailViewController(item: selectedNews)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func setupSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }
}

// MARK: - UITableView DataSource & Delegate
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.reuseIdentifier, for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.news[indexPath.row]
        let isBookmarked = viewModel.readingList.contains { $0.id == item.id }
        
        cell.configure(with: item, isBookMarked: isBookmarked)
        
        // MARK: - Action
        cell.onBookmarkToggled = { [weak self] _ in
            guard let self else { return }
            Task {
                await self.viewModel.toggleReadingList(item)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNews = viewModel.news[indexPath.row]
        didSelectNews(selectedNews)
    }
}

// MARK: - UISearchBar Delegate
extension HomeViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.search(text)
    }
}
                                    
