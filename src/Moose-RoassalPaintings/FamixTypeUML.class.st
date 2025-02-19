"
I show the UML representation of a FamixTType.
"
Class {
	#name : #FamixTypeUML,
	#superclass : #MooseAbstractVisualization,
	#instVars : [
		'builder'
	],
	#category : #'Moose-RoassalPaintings-FamixVisualizations'
}

{ #category : #accessing }
FamixTypeUML class >> defaultTitle [
	^ 'UML class diagram'
]

{ #category : #public }
FamixTypeUML class >> forType: aFamixType [
	^ self new
		famixType: aFamixType;
		yourself
]

{ #category : #public }
FamixTypeUML class >> forTypeGroup: aFamixTypeGroup [
	^ self new
		famixTypeGroup: aFamixTypeGroup;
		yourself
]

{ #category : #accessing }
FamixTypeUML class >> icon [
	^ MooseIcons mooseUml
]

{ #category : #building }
FamixTypeUML >> build [
	builder renderIn: self canvas.
	super build
]

{ #category : #building }
FamixTypeUML >> buildLegend [
	| legend |
	legend := RSLegend new.
	legend container: self canvas.
	legend onDemand.
	legend title: self class defaultTitle.
	legend build
]

{ #category : #accessing }
FamixTypeUML >> famixType: aFamixType [
	builder classes: {aFamixType}
]

{ #category : #accessing }
FamixTypeUML >> famixTypeGroup: aFamixTypeGroup [
	builder classes: aFamixTypeGroup
]

{ #category : #initialization }
FamixTypeUML >> initialize [
	super initialize.
	self initializeBuilder
]

{ #category : #initialization }
FamixTypeUML >> initializeBuilder [
	builder := RSUMLClassBuilder new.
	builder modelDescriptor
		instVars: [ :type | 
			(type attributes sorted: [ :a1 :a2 | a1 name < a2 name ])
				collect: #name ];
		methods: [ :type | type methods sorted: [ :m1 :m2 | m1 name < m2 name ] ];
		methodSelector: #name
]
