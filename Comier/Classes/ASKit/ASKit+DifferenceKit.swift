//
//  ASKit+DifferenceKit.swift
//  Comier
//
//  Created by Bách VQ on 21/07/2021.
//

import Foundation
import DifferenceKit
import UIKit
import AsyncDisplayKit

public extension ASCollectionNode {
	func reload<C>(
		using stagedChangeset: StagedChangeset<C>,
		performAction: () -> Void = {},
		interrupt: ((Changeset<C>) -> Bool)? = nil,
		animated: Bool = false,
		updateCellBlock: ((Any, ASCellNode?) -> Void)? = nil,
		setData: (C) -> Void,
		completion: ((Bool) -> Void)? = nil
	) {
		if case .none = self.view.window, let data = stagedChangeset.last?.data {
			setData(data)
			return reloadData()
		}
		
		if !animated {
			CATransaction.begin()
			CATransaction.setDisableActions(true)
		}
		
		performBatchUpdates({
			for changeset in stagedChangeset {
				setData(changeset.data)
				if !changeset.sectionDeleted.isEmpty {
					deleteSections(IndexSet(changeset.sectionDeleted))
				}
				
				if !changeset.sectionInserted.isEmpty {
					insertSections(IndexSet(changeset.sectionInserted))
				}
				
				if !changeset.sectionUpdated.isEmpty {
					reloadSections(IndexSet(changeset.sectionUpdated))
				}
				
				for (source, target) in changeset.sectionMoved {
					moveSection(source, toSection: target)
				}
				
				if !changeset.elementDeleted.isEmpty {
					deleteItems(at: changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
				}
				
				if !changeset.elementInserted.isEmpty {
					insertItems(at: changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
				}
				
				if !changeset.elementUpdated.isEmpty {
					if updateCellBlock != nil {
						changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) }.forEach { indexPath in
							let newValue = Array(changeset.data)[indexPath.item]
							let cell = self.nodeForItem(at: indexPath)
							updateCellBlock?(newValue, cell)
						}
					} else {
						reloadItems(at: changeset.elementUpdated.map { IndexPath(row: $0.element, section: $0.section)})
					}
				}
				
				for (source, target) in changeset.elementMoved {
					moveItem(at: IndexPath(item: source.element, section: source.section), to: IndexPath(item: target.element, section: target.section))
				}
			}
			performAction()
		}) { finished in
			if !animated {
				CATransaction.commit()
			}
			
			completion?(finished)
		}
	}
}

public extension ASTableNode {
	/// Applies multiple animated updates in stages using `StagedChangeset`.
	///
	/// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
	///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
	///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
	///
	/// - Parameters:
	///   - stagedChangeset: A staged set of changes.
	///   - animation: An option to animate the updates.
	///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
	///                updates should be stopped and performed reloadData. Default is nil.
	///   - setData: A closure that takes the collection as a parameter.
	///              The collection should be set to data-source of UITableView.
	func reload<C>(
		using stagedChangeset: StagedChangeset<C>,
		with animation: @autoclosure () -> UITableView.RowAnimation,
		updateRow: ((C.Element, ASCellNode?) -> Void)? = nil,
		interrupt: ((Changeset<C>) -> Bool)? = nil,
		setData: (C) -> Void
	) {
		reload(
			using: stagedChangeset,
			deleteSectionsAnimation: animation(),
			insertSectionsAnimation: animation(),
			reloadSectionsAnimation: animation(),
			deleteRowsAnimation: animation(),
			insertRowsAnimation: animation(),
			reloadRowsAnimation: animation(),
			updateRow: updateRow,
			interrupt: interrupt,
			setData: setData
		)
	}
	
	/// Applies multiple animated updates in stages using `StagedChangeset`.
	///
	/// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
	///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
	///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
	///
	/// - Parameters:
	///   - stagedChangeset: A staged set of changes.
	///   - deleteSectionsAnimation: An option to animate the section deletion.
	///   - insertSectionsAnimation: An option to animate the section insertion.
	///   - reloadSectionsAnimation: An option to animate the section reload.
	///   - deleteRowsAnimation: An option to animate the row deletion.
	///   - insertRowsAnimation: An option to animate the row insertion.
	///   - reloadRowsAnimation: An option to animate the row reload.
	///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
	///                updates should be stopped and performed reloadData. Default is nil.
	///   - setData: A closure that takes the collection as a parameter.
	///              The collection should be set to data-source of UITableView.
	func reload<C>(
		using stagedChangeset: StagedChangeset<C>,
		useAnimated: Bool = true,
		deleteSectionsAnimation: @autoclosure () -> UITableView.RowAnimation,
		insertSectionsAnimation: @autoclosure () -> UITableView.RowAnimation,
		reloadSectionsAnimation: @autoclosure () -> UITableView.RowAnimation,
		deleteRowsAnimation: @autoclosure () -> UITableView.RowAnimation,
		insertRowsAnimation: @autoclosure () -> UITableView.RowAnimation,
		reloadRowsAnimation: @autoclosure () -> UITableView.RowAnimation,
		updateRow: ((C.Element, ASCellNode?) -> Void)? = nil,
		interrupt: ((Changeset<C>) -> Bool)? = nil,
		setData: (C) -> Void
	) {
		if case .none = self.view.window, let data = stagedChangeset.last?.data {
			setData(data)
			return reloadData()
		}
		
		for changeset in stagedChangeset {
			if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
				setData(data)
				return reloadData()
			}
			
			_performBatchUpdates(animated: useAnimated) {
				setData(changeset.data)
				
				if !changeset.sectionDeleted.isEmpty {
					deleteSections(IndexSet(changeset.sectionDeleted), with: deleteSectionsAnimation())
				}
				
				if !changeset.sectionInserted.isEmpty {
					insertSections(IndexSet(changeset.sectionInserted), with: insertSectionsAnimation())
				}
				
				if !changeset.sectionUpdated.isEmpty {
					reloadSections(IndexSet(changeset.sectionUpdated), with: reloadSectionsAnimation())
				}
				
				for (source, target) in changeset.sectionMoved {
					moveSection(source, toSection: target)
				}
				
				if !changeset.elementUpdated.isEmpty {
					if updateRow != nil {
						changeset.elementUpdated.map { IndexPath(row: $0.element, section: $0.section) }.forEach { indexPath in
							let cell = self.nodeForRow(at: indexPath)
							let newValue = Array(changeset.data)[indexPath.row]
							updateRow?(newValue, cell)
						}
					} else {
						reloadRows(at: changeset.elementUpdated.map { IndexPath(row: $0.element, section: $0.section)}, with: reloadRowsAnimation())
					}
				}
				
				if !changeset.elementDeleted.isEmpty {
					deleteRows(at: changeset.elementDeleted.map { IndexPath(row: $0.element, section: $0.section) }, with: deleteRowsAnimation())
				}
				
				if !changeset.elementInserted.isEmpty {
					insertRows(at: changeset.elementInserted.map { IndexPath(row: $0.element, section: $0.section) }, with: insertRowsAnimation())
				}
				
				for (source, target) in changeset.elementMoved {
					moveRow(at: IndexPath(row: source.element, section: source.section), to: IndexPath(row: target.element, section: target.section))
				}
			}
		}
	}
	
	private func _performBatchUpdates(animated: Bool = false, updates: () -> Void) {
		performBatch(animated: animated, updates: updates, completion: nil)
	}
	
	func reloadWithoutAnimation<C>(
		using stagedChangeset: StagedChangeset<C>,
		updateRow: ((C.Element, ASCellNode?) -> Void)? = nil,
		interrupt: ((Changeset<C>) -> Bool)? = nil,
		setData: (C) -> Void
	) {
		reload(
			using: stagedChangeset,
			useAnimated: false,
			deleteSectionsAnimation: .none,
			insertSectionsAnimation: .none,
			reloadSectionsAnimation: .none,
			deleteRowsAnimation: .none,
			insertRowsAnimation: .none,
			reloadRowsAnimation: .none,
			updateRow: updateRow,
			interrupt: interrupt,
			setData: setData
		)
	}
}
