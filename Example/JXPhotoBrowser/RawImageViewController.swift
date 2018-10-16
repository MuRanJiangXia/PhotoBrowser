//
//  RawImageViewController.swift
//  JXPhotoBrowser_Example
//
//  Created by JiongXing on 2018/10/15.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import JXPhotoBrowser

class RawImageViewController: BaseCollectionViewController {
    override var name: String {
        return "网络图片-三级：缩略图、高清图和原图"
    }
    
    override func makeDataSource() -> [ResourceModel] {
        var result: [ResourceModel] = []
        guard let url = Bundle.main.url(forResource: "Photos", withExtension: "plist") else {
            return result
        }
        guard let data = try? Data.init(contentsOf: url) else {
            return result
        }
        let decoder = PropertyListDecoder()
        guard let array = try? decoder.decode([[String]].self, from: data) else {
            return result
        }
        array.forEach { item in
            let model = ResourceModel()
            model.firstLevelUrl = item[0]
            model.secondLevelUrl = item[1]
            result.append(model)
        }
        result[0].thirdLevelUrl = "http://seopic.699pic.com/photo/00040/8565.jpg_wh1200.jpg"
        return result
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.jx.dequeueReusableCell(BaseCollectionViewCell.self, for: indexPath)
        // 加载一级资源
        if let firstLevel = self.dataSource[indexPath.item].firstLevelUrl {
            let url = URL(string: firstLevel)
            cell.imageView.kf.setImage(with: url)
        } else {
            cell.imageView.kf.setImage(with: nil)
        }
        return cell
    }
    
    override func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath) {
        // 网图加载器
        let loader = JXPhotoBrowser.KingfisherLoader()
        // 数据源
        let dataSource = JXPhotoBrowser.RawImageDataSource(photoLoader: loader, numberOfItems: { () -> Int in
            return self.dataSource.count
        }, localImage: { index -> UIImage? in
            let cell = collectionView.cellForItem(at: indexPath) as? BaseCollectionViewCell
            return cell?.imageView.image
        }, autoloadURLString: { index -> String? in
            return self.dataSource[index].secondLevelUrl
        }) { index -> String? in
            return self.dataSource[index].thirdLevelUrl
        }
        // 视图代理，实现了光点型页码指示器
        let delegate = JXPhotoBrowser.DefaultPageControlDelegate()
        // 转场动画
        let trans = JXPhotoBrowser.ZoomTransitioning(presentingStartView: { (_, _) -> UIView? in
            return collectionView.cellForItem(at: indexPath)
        }, dismissingEndView: { (browser, _) -> UIView? in
            let indexPath = IndexPath(item: browser.pageIndex, section: 0)
            return collectionView.cellForItem(at: indexPath)
        })
        // 打开浏览器
        JXPhotoBrowser(dataSource: dataSource, delegate: delegate, transDelegate: trans)
            .show(pageIndex: indexPath.item)
    }
}