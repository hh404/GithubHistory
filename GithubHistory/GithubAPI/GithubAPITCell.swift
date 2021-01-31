//
//  GithubAPITCell.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/1/31.
//

import UIKit
import SnapKit

class GithubAPITCell: UITableViewCell {
    private var apiKeyLabel = UILabel(frame: .zero)
    private var apiValueLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(apiKeyLabel)
        self.contentView.addSubview(apiValueLabel)
        
        apiKeyLabel.font = UIFont.systemFont(ofSize: 12)
        apiKeyLabel.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        apiKeyLabel.numberOfLines = 0
        apiKeyLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        apiValueLabel.font = UIFont.boldSystemFont(ofSize: 14)
        apiValueLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        apiValueLabel.numberOfLines = 0
        apiValueLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(apiKeyLabel)
            make.top.equalTo(apiKeyLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setModel(key: String, value: String) -> Void {
        apiKeyLabel.text = key
        apiValueLabel.text = value
    }

}
