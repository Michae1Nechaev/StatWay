//
//  BenchAdapter.swift
//  StatVBL
//
//  Created by Михаил Нечаев on 02.11.2019.
//  Copyright © 2019 Michael Nechaev. All rights reserved.
//

import UIKit

final class BundleAdapter: NSObject {
    
    var activePlayer: PlayerStat?
    private var bundleStat: [PlayerStat]
    private var presenter: GamePresenterDelegate
    private let storage = Storage()

    init(bundleSet: [Player], presenter: GamePresenterDelegate) {
        bundleStat = [PlayerStat]()
        for player in bundleSet {
            let stat = PlayerStat(playerId: player.id)
            bundleStat.append(stat)
        }
        self.presenter = presenter
    }
    
    func makeSubstitution(with playerFromStart: PlayerStat) {
        guard let player = presenter.playerFromBundleForSubstitution else { return }
        if let index = bundleStat.firstIndex(of: player) {
            bundleStat.remove(at: index)
            bundleStat.insert(playerFromStart, at: index)
            presenter.updateBundleList()
        }
    }
    
    func savePlayersStats(for matchId: Int) {
        bundleStat.forEach { [weak self] (stat) in
            stat.matchId = matchId
            self?.storage.save(stat)
        }
    }

}

// MARK: - UITableViewDelegate

extension BundleAdapter: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard presenter.playerFromStartForSubstitution != nil else { return }
        presenter.confirmSubstitution(on: bundleStat[indexPath.row])
    }

}

// MARK: - UITableViewDataSource

extension BundleAdapter: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bundleStat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let unwrappedCell = tableView.dequeueReusableCell(withIdentifier: PlayerTableViewCell.nameOfClass, for: indexPath) as? PlayerTableViewCell else {
            return UITableViewCell()
        }
        guard let player = storage.getPlayer(by: bundleStat[indexPath.row].playerId) else {
            return UITableViewCell()
        }
        unwrappedCell.nameLabel.text = player.name
        unwrappedCell.surnameLabel.text = player.surname
        unwrappedCell.numberLabel.text = player.number
        return unwrappedCell
    }

}
