typealias AnyHashableCase = Hashable & CaseIterable

/// Calls the supplied `block` once for all cases in the inferred type conforming to `CaseIterable` with `Hashable` elements (e.g. an `enum`)
/// and flattens all the elements returned by each invokation of `block` into a single collection and returns it.
func reduce<CaseType: AnyHashableCase, Element>(allCasesIn block: (_ : CaseType) -> [Element], excluding excludedCase: CaseType) -> [Element] {
	var allCases = Set(CaseType.allCases)
	allCases.remove(excludedCase)
	
	return allCases.reduce(into: [Element]()) { allElements, iteratedCase in
		let elements = block(iteratedCase)
		allElements.append(contentsOf: elements)
	}
}

func map<Element, Structure>(_ collection: [Element], _ block: (_ offset: Int, _ element: Element) -> Structure) -> [Structure] {
	return collection.enumerated().map { enumeration -> Structure in
		let (offset, element) = enumeration
		let structure = block(offset, element)
		
		return structure
	}
}
