//
//  HomeTableViewCell.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 17.06.2026.
//

import UIKit
import SnapKit
import Kingfisher

final class NewsCell: UITableViewCell {
    
    static let reuseIdentifier: String = "NewsCell"
    
    private let mainStackView = UIStackView()
    private let newsImageView = UIImageView()
    
    private let seperateStackView = UIStackView()
    private let creatorLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let horizontalStackView = UIStackView()
    private let dateLabel = UILabel()
    private let readListButton = UIButton()
    
    var onBookmarkToggled: ((Bool) -> Void)?

    private var isBookMarked: Bool = false {
        didSet { updateBookMarkButton() }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsImageView.kf.cancelDownloadTask()
        newsImageView.image = nil
        onBookmarkToggled = nil
    }
    
    func configure(with items: NewsModel, isBookMarked: Bool) {
        configureImage(image: items.imageURL)
        creatorLabel.text = items.creatorText
        titleLabel.text = items.title
        descriptionLabel.text = items.description
        dateLabel.text = items.pubDate
        self.isBookMarked = isBookMarked
    }
    
    private func configureImage(image: String?) {
        guard let image = image, let url = URL(string: image) else {
            newsImageView.image = UIImage(resource: .news)
            return
        }
        
        newsImageView.kf.setImage(with: url)
    }
    
    // MARK: - Action
    
    private func updateBookMarkButton() {
        let imageName = isBookMarked ? "heart.fill" : "heart"
        readListButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func bookMarkTapped() {
        isBookMarked.toggle()
        onBookmarkToggled?(isBookMarked)
    }
    
    
}

private extension NewsCell {
    func setupViews() {
        selectionStyle = .none
        
        readListButton.addTarget(self, action: #selector(bookMarkTapped), for: .touchUpInside)
        
        mainStackView.axis = .horizontal
        mainStackView.spacing = 8
        mainStackView.alignment = .top
        
        seperateStackView.axis = .vertical
        seperateStackView.spacing = 4
        seperateStackView.alignment = .leading
        
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        newsImageView.layer.cornerRadius = 8
        
        creatorLabel.font = .systemFont(ofSize: 12, weight: .medium)
        creatorLabel.textColor = .secondaryLabel
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 2
        
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .secondaryLabel
        
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 4
        horizontalStackView.distribution = .fillProportionally
        
        dateLabel.font = .systemFont(ofSize: 8, weight: .light)
        dateLabel.textColor = .tertiaryLabel
        
        readListButton.setImage(UIImage(systemName: "heart"), for: .normal)
        readListButton.setTitleColor(.black, for: .normal)
        
        setupConstraints()
    }
    
    
    func setupConstraints() {
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubviews(
            newsImageView,
            seperateStackView
        )
        
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.leading.equalToSuperview().inset(16)
        }
        
        newsImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        horizontalStackView.addArrangedSubviews(
            dateLabel,
            readListButton
        )
        
        readListButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        
        seperateStackView.addArrangedSubviews(
            creatorLabel,
            titleLabel,
            descriptionLabel,
            horizontalStackView,
        )
    }
}
