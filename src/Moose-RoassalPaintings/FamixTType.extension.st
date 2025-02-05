Extension { #name : #FamixTType }

{ #category : #'*Moose-RoassalPaintings' }
FamixTType >> accessorMethods [
	
	^ self methods select: #isPureAccessor
]

{ #category : #'*Moose-RoassalPaintings' }
FamixTType >> blueprint [
	^ FamixTypeBlueprint forType: self
]

{ #category : #'*Moose-RoassalPaintings' }
FamixTType >> uml [
	^ FamixTypeUML forType: self
]
