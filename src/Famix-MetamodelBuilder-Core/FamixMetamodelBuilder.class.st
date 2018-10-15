"
builder := FamixMetamodelBuilder new.
builder 
	prefix: 'FamixTest';
	packageName: 'FamixTest'.

comment := builder newClassNamed: #Comment.
method := builder newClassNamed: #Method.
package := builder newClassNamed: #Package.

(package <>- comment)
	from
	




builder := FamixMetamodelBuilder new.

rel := builder newRelation 
	between: #TAccess and: #TWithAccesses;
	fromOne: #accessor toMany: #accesses.
	
	
rel := builder newRelation 
	between: #TAccess and: #TWithAccesses;
	fromOne: #accessor toMany: #accesses.
	
rel := builder newRelation
	from: [ :side |
		side name: #accessor;
			traitName: #TAccess;
			container;
			comment: 'some comment';
			one	 ];
	to: [ :opposite |
		opposite 	name: #accesses;
			traitName: #TWithAccesses;
			comment: 'ohter comment';
			many ].
		
	



"
Class {
	#name : #FamixMetamodelBuilder,
	#superclass : #Object,
	#instVars : [
		'environment',
		'classes',
		'traits',
		'relations',
		'generator',
		'testingSelectorsMapping',
		'configuration'
	],
	#category : #'Famix-MetamodelBuilder-Core-Basic'
}

{ #category : #'instance creation' }
FamixMetamodelBuilder class >> forGenerator: aGenerator [

	^ self new
		generator: aGenerator;
		yourself.
]

{ #category : #visitor }
FamixMetamodelBuilder >> acceptVisitor: aVisitor [

	^ aVisitor visitBuilder: self.
]

{ #category : #accessing }
FamixMetamodelBuilder >> apply [

	self environment apply
]

{ #category : #accessing }
FamixMetamodelBuilder >> baseImportingContextName [

	^ #FmxImportingContext
]

{ #category : #accessing }
FamixMetamodelBuilder >> behaviorsCount [

	^ self traits size + self sortedClasses size
]

{ #category : #accessing }
FamixMetamodelBuilder >> classes [
	^ classes
]

{ #category : #accessing }
FamixMetamodelBuilder >> classesThatDirectlyUse: aTrait [

	^ self classes select: [ :each | each allLocalTraits includes: aTrait ].
]

{ #category : #accessing }
FamixMetamodelBuilder >> classesThatUse: aTrait [

	^ self classes select: [ :each | each allTraitsInHierarchy includes: aTrait ].
]

{ #category : #accessing }
FamixMetamodelBuilder >> classesToGenerate [ 

	^ self classes select: #willGenerate
]

{ #category : #accessing }
FamixMetamodelBuilder >> configuration [
	^ configuration
]

{ #category : #accessing }
FamixMetamodelBuilder >> configuration: anObject [
	configuration := anObject
]

{ #category : #accessing }
FamixMetamodelBuilder >> containerRequirementsOf: aClass [

	|  usedBehaviors |
	
	usedBehaviors := aClass containerProperties collect: [ :e | e relation oppositeSide relatedEntity].
	^ usedBehaviors flatCollect: [:aBehavior |
		aBehavior isMetamodelTrait
			ifTrue: [ self classes select: [ :e | e hasTraitGeneralization: aBehavior ]]
			ifFalse: [ {aBehavior} ]]
]

{ #category : #accessing }
FamixMetamodelBuilder >> doNotGenerateCurrent [

	self classes do: [ :each | each willGenerate: false ].
	self traits do: [ :each | each willGenerate: false ].
	
]

{ #category : #initialization }
FamixMetamodelBuilder >> ensureClassNamed: aString [

	| candidates |
	
	candidates := self classes select: [ :each | each name = aString].
	
	self assert: (candidates size <= 1).
	
	^ (candidates size = 1)
		ifTrue: [ candidates anyOne ]
		ifFalse: [ self newClassNamed: aString ]
	

]

{ #category : #initialization }
FamixMetamodelBuilder >> ensureLocalTraitNamed: aString [

	^ self traits detect: [ :each | each name = aString and: [each prefix = self configuration prefix]] ifNone: [ self newTraitNamed: aString ]

]

{ #category : #initialization }
FamixMetamodelBuilder >> ensureTraitNamed: aString [

	| candidates |
	
	candidates := self traits select: [ :each | each name = aString].
	
	self assert: (candidates size <= 1).
	
	^ (candidates size = 1)
		ifTrue: [ candidates anyOne ]
		ifFalse: [ self newTraitNamed: aString ]
	
]

{ #category : #accessing }
FamixMetamodelBuilder >> environment [
	^ environment
]

{ #category : #accessing }
FamixMetamodelBuilder >> environment: anObject [
	environment := anObject
]

{ #category : #generating }
FamixMetamodelBuilder >> generate [

	self resolveRequirementsFromContainers.

	self registerPackages.

	self traits do: [ :each | 
		self testingSelectorsMapping addAll: each testingSelectors. ].
	self sortedClasses do: [ :each | 
		self testingSelectorsMapping addAll: each testingSelectors. ].

	self traits do: [ :each | each generate ] displayingProgress: 'generating traits'.
	self sortedClasses do: [ :each | each generate ] displayingProgress: 'generating classes'.

	self traits do: [ :each | each generateNavigationGroups ] displayingProgress: 'generating navigation groups for traits'.
	self sortedClasses do: [ :each | each generateNavigationGroups ] displayingProgress: 'generating navigation groups for classes'.

	self behaviorsCount > 0
		ifTrue: [ self generateImportingContext ].
		
	self apply
]

{ #category : #generating }
FamixMetamodelBuilder >> generateImportIn: contextClass [

	| source |

	self sortedClasses do: [ :each | 
		source := String streamContents: [ :s |
			s	nextPutAll: 'import'; nextPutAll: each name; cr;
				cr;
				tab; nextPutAll: '<generated>'; cr;
				tab; nextPutAll: '^ self import: '; nextPutAll: each fullName ].
		 self environment compile: source in: contextClass classified: 'testing' ] 

]

{ #category : #generating }
FamixMetamodelBuilder >> generateImportingContext [

	| contextClass |
	
	self configuration wantsToGenerateImportingContext ifFalse: [ ^ self ].

	contextClass := self environment createImportingcontextClassNamed: self importingContextName in: self configuration packageName.
	
	self generateShouldImportIn: contextClass.
	self generateImportIn: contextClass
]

{ #category : #generating }
FamixMetamodelBuilder >> generateShouldImportIn: contextClass [

	| source |

	self sortedClasses do: [ :each | 
		source := String streamContents: [ :s |
			s	nextPutAll: 'shouldImport'; nextPutAll: each name; cr;
				cr;
				tab; nextPutAll: '<generated>'; cr;
				tab; nextPutAll: '^ self shouldImport: '; nextPutAll: each fullName ].
		 self environment compile: source in: contextClass classified: 'testing' ] 

]

{ #category : #accessing }
FamixMetamodelBuilder >> generator [
	^ generator
]

{ #category : #accessing }
FamixMetamodelBuilder >> generator: aGenerator [

	<ignoreForCoverage>
	generator := aGenerator.

]

{ #category : #accessing }
FamixMetamodelBuilder >> importingContextName [

	^ (self configuration prefix, 'ImportingContext') asSymbol
]

{ #category : #initialization }
FamixMetamodelBuilder >> initialize [

	environment := FmxMBRealRingEnvironment for: self.
	
	configuration := FmxMBConfiguration new.

	classes := OrderedCollection new.
	traits := OrderedCollection new.
	relations := OrderedCollection new.
	testingSelectorsMapping := Set new.	
	
	
]

{ #category : #initialization }
FamixMetamodelBuilder >> newClass [

	| aClass |
	
	aClass := FmxMBClass new.
	aClass builder: self.
	aClass prefix: self configuration prefix.
	aClass packageName: self configuration packageName.
	self classes add: aClass.
	^ aClass
	
]

{ #category : #initialization }
FamixMetamodelBuilder >> newClassNamed: aClassName [

	| candidates |
	
	candidates := self classes select: [ :each | each name = aClassName].
	candidates isEmpty ifFalse: [ FmxMBEntityAlreadyExists signal ].

	^ self newClass name: aClassName.
	
]

{ #category : #initialization }
FamixMetamodelBuilder >> newClassNamed: aClassName comment: aString [

	^ (self newClassNamed: aClassName)
		comment: aString;
		yourself
	
]

{ #category : #initialization }
FamixMetamodelBuilder >> newRelation [

	| aRelation |
	
	aRelation := FmxMBRelation new.
	aRelation builder: self.
	self relations add: aRelation.
	^ aRelation
]

{ #category : #initialization }
FamixMetamodelBuilder >> newTrait [ 

	| aTrait |
	
	aTrait := FmxMBTrait new.
	aTrait builder: self.
	aTrait prefix: self configuration prefix.
	aTrait packageName: self configuration packageName.
	self traits add: aTrait.
	^ aTrait
	
]

{ #category : #initialization }
FamixMetamodelBuilder >> newTraitNamed: aTraitName [

	| candidates |
	
	candidates := self traits select: [ :each | each name = aTraitName].
	candidates isEmpty ifFalse: [ FmxMBEntityAlreadyExists signal ].

	^ self newTrait name: aTraitName.

]

{ #category : #initialization }
FamixMetamodelBuilder >> newTraitNamed: aClassName comment: aString [

	^ (self newTraitNamed: aClassName)
		comment: aString;
		yourself
	
]

{ #category : #generating }
FamixMetamodelBuilder >> registerPackages [
	
	self environment registerPackage: self configuration packageName.
	
]

{ #category : #accessing }
FamixMetamodelBuilder >> relations [
	^ relations
]

{ #category : #generating }
FamixMetamodelBuilder >> resolveRequirementsFromContainers [

	self classes do: [ :each |
		| req |
		req := self containerRequirementsOf: each.
		each requires: (self containerRequirementsOf: each) ].

]

{ #category : #accessing }
FamixMetamodelBuilder >> safeAnnotationPackageName [
	
	| aName |
	
	aName := self configuration packageNameForAnnotations.
	
	^ aName isLiteralSymbol
		ifTrue: [ ^ '#', aName ]
		ifFalse: [ ^ '#''', aName, '''' ]
]

{ #category : #accessing }
FamixMetamodelBuilder >> sortedClasses [

	^ self classes sorted: [ :a :b |
		a allClassGeneralizations size <= b allClassGeneralizations size ].

]

{ #category : #accessing }
FamixMetamodelBuilder >> sortedTraits [

	^ self traits sorted: [ :a :b | a name <= b name].

]

{ #category : #'tests support' }
FamixMetamodelBuilder >> testingEnvironment [

	^ self environment ringEnvironment
]

{ #category : #accessing }
FamixMetamodelBuilder >> testingSelectorsMapping [
	^ testingSelectorsMapping
]

{ #category : #initialization }
FamixMetamodelBuilder >> traitNamed: aTraitName [

	^ self traits detect: [ :each | each name = aTraitName].
]

{ #category : #accessing }
FamixMetamodelBuilder >> traits [
	^ traits
]

{ #category : #accessing }
FamixMetamodelBuilder >> traitsToGenerate [ 

	^ self traits select: #willGenerate
]

{ #category : #accessing }
FamixMetamodelBuilder >> withImportingContext [

	self configuration wantsToGenerateImportingContext: true
]