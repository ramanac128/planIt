//
//  JTAppleCalendarDelegates.swift
//  Pods
//
//  Created by JayT on 2016-05-12.
//
//

// MARK: CollectionView delegates
extension JTAppleCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    /// Asks your data source object to provide a supplementary view to display in the collection view.
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let validDate = dateFromSection((indexPath as NSIndexPath).section) else {
            assert(false, "Date could not be generated fro section. This is a bug. Contact the developer")
            return UICollectionReusableView()
        }
        let reuseIdentifier: String
        var source: JTAppleCalendarViewSource = registeredHeaderViews[0]
        
        // Get the reuse identifier and index
        if registeredHeaderViews.count == 1 {
            switch registeredHeaderViews[0] {
            case let .fromXib(xibName, _): reuseIdentifier = xibName
            case let .fromClassName(className): reuseIdentifier = className
            case let .fromType(classType): reuseIdentifier = classType.description()
            }
        } else {
            reuseIdentifier = delegate!.calendar(self, sectionHeaderIdentifierForDate: validDate.dateRange, belongingTo: validDate.month)
            for item in registeredHeaderViews {
                switch item {
                case let .fromXib(xibName, _) where xibName == reuseIdentifier:
                    source = item
                    break
                case let .fromClassName(className) where className == reuseIdentifier:
                    source = item
                    break
                case let .fromType(type) where type.description() == reuseIdentifier:
                    source = item
                    break
                default:
                    continue
                }
            }
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! JTAppleCollectionReusableView
        headerView.setupView(source)
        headerView.update()
        delegate?.calendar(self, isAboutToDisplaySectionHeader: headerView.view!, dateRange: validDate.dateRange, identifier: reuseIdentifier)
        return headerView
    }
    
//    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        delegate?.calendar(self, isAboutToResetCell: (cell as! JTAppleDayCell).view!)
//    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        restoreSelectionStateForCellAtIndexPath(indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! JTAppleDayCell
        
        cell.setupView(cellViewSource)
        cell.updateCellView(cellInset.x, cellInsetY: cellInset.y)
        cell.bounds.origin = CGPoint(x: 0, y: 0)
        
        let date = dateFromPath(indexPath)!
        let cellState = cellStateFromIndexPath(indexPath, withDate: date)
        
        delegate?.calendar(self, isAboutToDisplayCell: cell.view!, date: date, cellState: cellState)

        return cell
    }
    /// Asks your data source object for the number of sections in the collection view. The number of sections in collectionView.
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthInfo.count
    }

    /// Asks your data source object for the number of items in the specified section. The number of rows in section.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  MAX_NUMBER_OF_DAYS_IN_WEEK * cachedConfiguration.numberOfRows
    }
    /// Asks the delegate if the specified item should be selected. true if the item should be selected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if let
            delegate = self.delegate,
            let dateUserSelected = dateFromPath(indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell
        ,
            cellWasNotDisabledOrHiddenByTheUser(cell) {
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateUserSelected)
            return delegate.calendar(self, canSelectDate: dateUserSelected, cell: cell.view!, cellState: cellState)
        }
        return false
    }
    
    func cellWasNotDisabledOrHiddenByTheUser(_ cell: JTAppleDayCell) -> Bool {
        return cell.view!.isHidden == false && cell.view!.isUserInteractionEnabled == true
    }
    
    /// Tells the delegate that the item at the specified path was deselected. The collection view calls this method when the user successfully deselects an item in the collection view. It does not call this method when you programmatically deselect items.
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let indexPathsToBeReloaded = rangeSelectionWillBeUsed ? validForwardAndBackwordSelectedIndexes(forIndexPath: indexPath) : [IndexPath]()
        internalCollectionView(collectionView, didDeselectItemAtIndexPath: indexPath, indexPathsToReload: indexPathsToBeReloaded)
    }
    func internalCollectionView(_ collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: IndexPath, indexPathsToReload: [IndexPath] = []) {
        if let
            delegate = self.delegate,
            let dateDeselectedByUser = dateFromPath(indexPath) {
            
            // Update model
            deleteCellFromSelectedSetIfSelected(indexPath)
            
            let selectedCell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell // Cell may be nil if user switches month sections
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateDeselectedByUser, cell: selectedCell) // Although the cell may be nil, we still want to return the cellstate
            var pathsToReload = indexPathsToReload
            if let anUnselectedCounterPartIndexPath = deselectCounterPartCellIndexPath(indexPath, date: dateDeselectedByUser, dateOwner: cellState.dateBelongsTo) {
                deleteCellFromSelectedSetIfSelected(anUnselectedCounterPartIndexPath)
                // ONLY if the counterPart cell is visible, then we need to inform the delegate
                if !pathsToReload.contains(anUnselectedCounterPartIndexPath){ pathsToReload.append(anUnselectedCounterPartIndexPath) }
            }
            if pathsToReload.count > 0 {
                delayRunOnMainThread(0.0) {
                    self.batchReloadIndexPaths(pathsToReload)
                }
            }
            delegate.calendar(self, didDeselectDate: dateDeselectedByUser, cell: selectedCell?.view, cellState: cellState)
        }
    }
    
    /// Asks the delegate if the specified item should be deselected. true if the item should be deselected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let
            delegate = self.delegate,
            let dateDeSelectedByUser = dateFromPath(indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell
        , cellWasNotDisabledOrHiddenByTheUser(cell) {
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateDeSelectedByUser)
            return delegate.calendar(self, canDeselectDate: dateDeSelectedByUser, cell: cell.view!, cellState:  cellState)
        }
        return false
    }
    
    /// Tells the delegate that the item at the specified index path was selected. The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // index paths to be reloaded should be index to the left and right of the selected index
        let indexPathsToBeReloaded = rangeSelectionWillBeUsed ? validForwardAndBackwordSelectedIndexes(forIndexPath: indexPath) : [IndexPath]()
        internalCollectionView(collectionView, didSelectItemAtIndexPath: indexPath, indexPathsToReload: indexPathsToBeReloaded)
    }
    
    func internalCollectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath, indexPathsToReload: [IndexPath] = []) {
        if let
            delegate = self.delegate,
            let dateSelectedByUser = dateFromPath(indexPath) {
            
            // Update model
            addCellToSelectedSetIfUnselected(indexPath, date:dateSelectedByUser)
            let selectedCell = collectionView.cellForItem(at: indexPath) as? JTAppleDayCell
            
            // If cell has a counterpart cell, then select it as well
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateSelectedByUser, cell: selectedCell)
            var pathsToReload = indexPathsToReload
            if let aSelectedCounterPartIndexPath = selectCounterPartCellIndexPathIfExists(indexPath, date: dateSelectedByUser, dateOwner: cellState.dateBelongsTo) {
                // ONLY if the counterPart cell is visible, then we need to inform the delegate
                if !pathsToReload.contains(aSelectedCounterPartIndexPath) && calendarView.indexPathsForVisibleItems.contains(aSelectedCounterPartIndexPath){
                    pathsToReload.append(aSelectedCounterPartIndexPath)
                }
            }
            if pathsToReload.count > 0 {
                delayRunOnMainThread(0.0) {
                    self.batchReloadIndexPaths(pathsToReload)
                }
            }
            
            delegate.calendar(self, didSelectDate: dateSelectedByUser, cell: selectedCell?.view, cellState: cellState)
        }
    }
}

extension JTAppleCalendarView: UIScrollViewDelegate {
    /// Inform the scrollViewDidEndDecelerating function that scrolling just occurred
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.scrollViewDidEndDecelerating(calendarView)
    }
    
    /// Tells the delegate when the user finishes scrolling the content.
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let saveLastContentOffset = { self.lastSavedContentOffset = self.direction == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y }
        let cachedDecelerationRate = calendarView.decelerationRate
        let theCurrentSection = currentSectionPage
        let contentSizeEndOffset: CGFloat
        var contentOffset: CGFloat = 0,
        theTargetContentOffset: CGFloat = 0,
        directionVelocity: CGFloat = 0
        
        let calendarLayout = (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
        if direction == .horizontal {
            contentOffset = scrollView.contentOffset.x
            theTargetContentOffset = targetContentOffset.pointee.x
            directionVelocity = velocity.x
            contentSizeEndOffset = scrollView.contentSize.width - scrollView.frame.width
        } else {
            contentOffset = scrollView.contentOffset.y
            theTargetContentOffset = targetContentOffset.pointee.y
            directionVelocity = velocity.y
            contentSizeEndOffset = scrollView.contentSize.height - scrollView.frame.height
        }
        
        let isScrollingForward = {return directionVelocity > 0 || contentOffset > self.lastSavedContentOffset}
        
        let isNotScrolling = {return contentOffset == self.lastSavedContentOffset}
        if isNotScrolling() { return }
        if directionVelocity == 0.0 { calendarView.decelerationRate = UIScrollViewDecelerationRateFast }
        
        
        
        let setTargetContentOffset = {(finalOffset: CGFloat) -> Void in
            if self.direction == .horizontal {
                targetContentOffset.pointee.x = finalOffset
            } else {
                targetContentOffset.pointee.y = finalOffset
            }
        }
        
        let calculatedCurrentFixedContentOffsetFrom = {(interval: CGFloat)->CGFloat in
            if isScrollingForward() {
                return ceil(contentOffset / interval) * interval
            } else {
                return floor(contentOffset / interval) * interval
            }
        }
        
        let recalculateOffset = {(diff: CGFloat, interval: CGFloat)-> CGFloat in
            if isScrollingForward() {
                let recalcOffsetAfterResistanceApplied = theTargetContentOffset - diff
                return ceil(recalcOffsetAfterResistanceApplied / interval) * interval
            } else {
                let recalcOffsetAfterResistanceApplied = theTargetContentOffset + diff
                return floor(recalcOffsetAfterResistanceApplied / interval) * interval
            }
        }
        
        let scrollViewShouldStopAtBeginning = {()->Bool in return contentOffset < 0 && theTargetContentOffset == 0 ? true : false}
        let scrollViewShouldStopAtEnd = {(calculatedOffSet: CGFloat)->Bool in return calculatedOffSet > contentSizeEndOffset }
        
        
        switch scrollingMode {
        case let .stopAtEach(customInterval: interval):
            let calculatedOffset = calculatedCurrentFixedContentOffsetFrom(interval)
            setTargetContentOffset(calculatedOffset)
        case .stopAtEachCalendarFrameWidth:
            #if os(tvOS)
                let interval = self.direction == .horizontal ? scrollView.frame.width : scrollView.frame.height
                let calculatedOffset = calculatedCurrentFixedContentOffsetFrom(interval)
                setTargetContentOffset(calculatedOffset)
            #endif
            break
        case .stopAtEachSection:
            var calculatedOffSet: CGFloat = 0
            if self.direction == .horizontal || (self.direction == .vertical && self.registeredHeaderViews.count < 1) {
                // Horizontal has a fixed width. Vertical with no header has fixed height
                let interval = calendarLayout.sizeOfContentForSection(theCurrentSection)
                calculatedOffSet = calculatedCurrentFixedContentOffsetFrom(interval)
            } else {
                // Vertical with headers have variable heights. It needs to be calculated
                let currentScrollOffset = scrollView.contentOffset.y
                let currentScrollSection = calendarLayout.sectionFromOffset(currentScrollOffset)
                var sectionSize: CGFloat = 0
                
                if isScrollingForward() {
                    sectionSize = calendarLayout.sectionSize[currentScrollSection]
                    calculatedOffSet = sectionSize
                } else {
                    if currentScrollSection - 1  >= 0 {
                        calculatedOffSet = calendarLayout.sectionSize[currentScrollSection - 1]
                    }
                }
            }
            setTargetContentOffset(calculatedOffSet)
        case .nonStopToSection, .nonStopToCell, .nonStopTo:
            let diff = abs(theTargetContentOffset - contentOffset)
            let targetSection = calendarLayout.sectionFromOffset(theTargetContentOffset)
            var calculatedOffSet = contentOffset
            
            switch scrollingMode {
            case let .nonStopToSection(resistance):
                
                let interval = calendarLayout.sizeOfContentForSection(targetSection)
                let diffResistance = diff * resistance
                
                if direction == .horizontal {
                    calculatedOffSet = recalculateOffset(diffResistance, interval)
                } else {
                    if isScrollingForward() {
                        calculatedOffSet = theTargetContentOffset - diffResistance
                    } else {
                        calculatedOffSet = theTargetContentOffset + diffResistance
                    }
                    let stopSection = isScrollingForward() ? calendarLayout.sectionFromOffset(calculatedOffSet) : calendarLayout.sectionFromOffset(calculatedOffSet) - 1
                    calculatedOffSet = stopSection < 0 ? 0 : calendarLayout.sectionSize[stopSection]
                }
                
                setTargetContentOffset(calculatedOffSet)
            case let .nonStopToCell(resistance):
                let interval = calendarLayout.cellCache[targetSection]![0].frame.width
                let diffResistance = diff * resistance
                if direction == .horizontal {
                    if scrollViewShouldStopAtBeginning() {
                        calculatedOffSet = 0
                    } else if scrollViewShouldStopAtEnd(calculatedOffSet) {
                        calculatedOffSet = theTargetContentOffset
                    } else {
                        calculatedOffSet = recalculateOffset(diffResistance, interval)
                    }
                } else {
                    var stopSection: Int
                    if isScrollingForward() {
                        calculatedOffSet =  scrollViewShouldStopAtEnd(calculatedOffSet) ? theTargetContentOffset : theTargetContentOffset - diffResistance
                        stopSection = calendarLayout.sectionFromOffset(calculatedOffSet)
                    } else {
                        calculatedOffSet = scrollViewShouldStopAtBeginning() ? 0 : theTargetContentOffset + diffResistance
                        stopSection = calendarLayout.sectionFromOffset(calculatedOffSet)
                    }
                    if contentOffset > 0, let path = self.calendarView.indexPathForItem(at: CGPoint(x: targetContentOffset.pointee.x, y: calculatedOffSet)) {
                        let attrib = self.calendarView.layoutAttributesForItem(at: path)!
                        if isScrollingForward() {
                            calculatedOffSet = attrib.frame.origin.y + attrib.frame.size.height
                        } else {
                            calculatedOffSet = attrib.frame.origin.y
                        }
                    } else if registeredHeaderViews.count > 0, let attrib = self.calendarView.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: (IndexPath(item: 0, section: stopSection))) {
                        // change the final value to the end of the header
                        if isScrollingForward() {
                            calculatedOffSet = attrib.frame.origin.y + attrib.frame.size.height
                        } else {
                            calculatedOffSet =  stopSection - 1 < 0 ? 0 : calendarLayout.sectionSize[stopSection - 1]
                        }
                    }
                }
                setTargetContentOffset(calculatedOffSet)
            case let .nonStopTo(interval, resistance): // Both horizontal and vertical are fixed
                let diffResistance = diff * resistance
                calculatedOffSet = recalculateOffset(diffResistance, interval)
                setTargetContentOffset(calculatedOffSet)
            default:
                break
            }
            
        default:
            // If we go through this route, then no animated scrolling was done. User scrolled and stopped and lifted finger. Thus update the label.
            delayRunOnMainThread(0.0) {
                self.scrollViewDidEndDecelerating(self.calendarView)
            }
        }
        
        saveLastContentOffset()
        delayRunOnMainThread(0.7) {
            self.calendarView.decelerationRate = cachedDecelerationRate
        }
    }
    
    /// Tells the delegate when a scrolling animation in the scroll view concludes.
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let shouldTrigger = triggerScrollToDateDelegate , shouldTrigger == true {
            scrollViewDidEndDecelerating(scrollView)
            triggerScrollToDateDelegate = nil
        }
        executeDelayedTasks()
        
        // A scroll was just completed.
        scrollInProgress = false
    }
    
    /// Tells the delegate that the scroll view has ended decelerating the scrolling movement.
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentSegmentDates = currentCalendarDateSegment()
        self.delegate?.calendar(self, didScrollToDateSegmentStartingWithdate: currentSegmentDates.dateRange.start, endingWithDate: currentSegmentDates.dateRange.end)
    }
}
