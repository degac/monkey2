
Namespace mojox

#rem monkeydoc The FileBrowser class.
#end
Class FileBrowser Extends TreeView


	#rem monkeydoc Invoked when a file is clicked.
	#end
	Field FileClicked:Void( path:String )

	#rem monkeydoc Invoked when a file is right clicked.
	#end
	Field FileRightClicked:Void( path:String )

	#rem monkeydoc Invoked when a file is double clicked.
	#end
	Field FileDoubleClicked:Void( path:String )

	#rem monkeydoc Creates a new FileBrowser.
	#end
	Method New( rootPath:String="." )
		Style=GetStyle( "FileBrowser" )
		
		GetFileTypeIcons()
	
		_rootNode=New Node( Null )
		
		RootPath=rootPath

		NodeClicked=OnNodeClicked
		NodeRightClicked=OnNodeRightClicked
		NodeDoubleClicked=OnNodeDoubleClicked
		
		NodeExpanded=OnNodeExpanded
		NodeCollapsed=OnNodeCollapsed
		
		RootNode=_rootNode
		
		Update()
	End
	#rem monkeydoc Set what Files should be excluded. Values separated by commas.
	#end
	Property ExcludedFile:String()
		Return _excluded_file
	Setter(_e:String)
		_excluded_file=_e
	End
	#rem monkeydoc Set what Folders should be excluded. Values separated by commas.
	#end
	Property ExcludedFolder:String()
		Return _excluded_folder
	Setter(_e:String)
		_excluded_folder=_e
	End
	
	
	
	
	#rem monkeydoc Root path of browser.
	#end
	Property RootPath:String()
	
		Return _rootPath
	
	Setter( path:String )
	
		_rootPath=path
		
		_rootNode._path=path
		_rootNode.Text=_rootPath
	End
	
	#rem monkeydoc Updates the browser.
	#end
	Method Update()
	
		UpdateNode( _rootNode,_rootPath,True )
	End
	
	Protected
	
	Method OnValidateStyle() Override

		Super.OnValidateStyle()
			
		GetFileTypeIcons()
		
		_dirIcon=_fileTypeIcons["._dir"]
		_fileIcon=_fileTypeIcons["._file"]
	End

	Private
	
	Class Node Extends TreeView.Node
	
		Method New( parent:Node )
			Super.New( "",parent )
		End
		
		Private
		
		Field _path:String
	End
	
	Field _rootNode:Node
	Field _rootPath:String
	
	Field _dirIcon:Image
	Field _fileIcon:Image
	
	Method OnNodeClicked( tnode:TreeView.Node )
	
		Local node:=Cast<Node>( tnode )
		If Not node Return
		
		FileClicked( node._path )
	End
	
	Method OnNodeRightClicked( tnode:TreeView.Node )
	
		Local node:=Cast<Node>( tnode )
		If Not node Return
		
		FileRightClicked( node._path )
	End
	
	Method OnNodeDoubleClicked( tnode:TreeView.Node )
	
		Local node:=Cast<Node>( tnode )
		If Not node Return
		
		FileDoubleClicked( node._path )
	End
	
	Method OnNodeExpanded( tnode:TreeView.Node )
	
		Local node:=Cast<Node>( tnode )
		If Not node Return
		
		UpdateNode( node,node._path,True )
	End
	
	Method OnNodeCollapsed( tnode:TreeView.Node )
	
		Local node:=Cast<Node>( tnode )
		If Not node Return
		
		For Local child:=Eachin node.Children
			child.RemoveAllChildren()
		Next
		
	End
	
	Method UpdateNode( node:Node,path:String,recurse:Bool )
	
		If Not path.EndsWith( "/" ) path+="/"
		Local dir:=filesystem.LoadDir( path )
		
		Local dirs:=New Stack<String>
		Local files:=New Stack<String>
	
		For Local f:=Eachin dir
			Local fpath:=path+"/"+f
			Select GetFileType( fpath )
			Case FileType.Directory
				for Local ef:=Eachin _excluded_folder.Split(",")
					If fpath.ToLower().Contains(ef.ToLower())=True f=""
				Next
				If f<>"" dirs.Push( f )
			Default
				For Local ef:=Eachin _excluded_file.Split(",")	
					If f.ToLower().Contains(ef.ToLower())=True f=""
				Next
			
				If f<>""	files.Push( f )
			End
		Next
		

		
		dirs.Sort()
		files.Sort()
		
		Local i:=0,children:=node.Children
		Local total_size:=dirs.Length+files.Length
		
		While i<total_size
		
			Local f:=""
			If i<dirs.Length f=dirs[i] Else f=files[i-dirs.Length]
			
			Local child:Node
			
			If i<children.Length
				child=Cast<Node>( children[i] )
			Else
				child=New Node( node )
			Endif
			
			Local fpath:=path+f
			
			child.Text=f
			child._path=fpath
			
			Local icon:=_fileTypeIcons[ExtractExt( f ).ToLower()]
			
			If i<dirs.Length
				If Not icon icon=_dirIcon
				child.Icon=icon
				If child.Expanded Or recurse
					UpdateNode( child,fpath,child.Expanded )
				Endif
			Else
				If Not icon icon=_fileIcon
				child.Icon=icon
				child.RemoveAllChildren()
			Endif
			
			i+=1
		Wend
		
		node.RemoveChildren( i )
		
	End
	
	Function GetFileTypeIcons:StringMap<Image>()
	
		If _fileTypeIcons Return _fileTypeIcons
		
		_fileTypeIcons=New StringMap<Image>
		
		Local dir:="theme::filetype_icons/"
		
		Local types:=stringio.LoadString( dir+"filetypes.txt" ).Split( "~n" )
	
		For Local type:=Eachin types
		
			type=type.Trim()
			If Not type Continue
			
			Local icon:=Image.Load( dir+type )
			If Not icon Continue
			
			_fileTypeIcons[ "."+StripExt(type) ]=icon
		Next
		
		Return _fileTypeIcons
	End
	

	
	Private

		
	Global _fileTypeIcons:StringMap<Image>
	Global _excluded_file:String
	Global _excluded_folder:String
End

