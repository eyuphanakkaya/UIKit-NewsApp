//
//  DetailViewController.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 17.06.2026.
//

import UIKit
import Kingfisher
import SnapKit

final class DetailViewController: UIViewController {
    private let scrollView = CustomScrollView()
    private let dateLabel = UILabel()
    private let creatorLabel = UILabel()
    private let titleLabel = UILabel()
    private let detailImageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    private let item: NewsModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configure()
    }
    
    init(item: NewsModel) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        dateLabel.text = item.pubDate
        creatorLabel.text = item.creatorText
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        configureImage(image: item.imageURL)
    }
    
    private func configureImage(image: String?) {
        guard let image = image, let url = URL(string: image) else {
            detailImageView.image = UIImage(named: "placeholder")
            return
        }
        
        detailImageView.kf.setImage(with: url)
    }
    
}

private extension DetailViewController {
    func setupViews() {
        view.backgroundColor = .systemBackground
        
        scrollView.spacing = 16
        
        dateLabel.font = .systemFont(ofSize: 16, weight: .light)
        dateLabel.numberOfLines = 1
        dateLabel.textColor = .tertiaryLabel
        
        creatorLabel.font = .systemFont(ofSize: 12, weight: .light)
        creatorLabel.numberOfLines = 1
        creatorLabel.textColor = .tertiaryLabel
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 0
        
        detailImageView.contentMode = .scaleAspectFill
        detailImageView.clipsToBounds = true
        detailImageView.layer.cornerRadius = 32
        
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .secondaryLabel
        
        setupConstraints()
    }
    
    func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.stackView.addArrangedSubviews(
            dateLabel,
            creatorLabel,
            titleLabel,
            detailImageView,
            descriptionLabel
        )
        
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.trailing.leading.equalToSuperview().inset(16)
        }
        
        detailImageView.snp.makeConstraints {
            $0.height.equalTo(220)
        }
    }
}
