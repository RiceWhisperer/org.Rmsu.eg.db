datacache <- new.env(hash=TRUE, parent=emptyenv())

org.Rmsu.eg <- function() showQCData("org.Rmsu.eg", datacache)
org.Rmsu.eg_dbconn <- function() dbconn(datacache)
org.Rmsu.eg_dbfile <- function() dbfile(datacache)
org.Rmsu.eg_dbschema <- function(file="", show.indices=FALSE) dbschema(datacache, file=file, show.indices=show.indices)
org.Rmsu.eg_dbInfo <- function() dbInfo(datacache)

org.Rmsu.egORGANISM <- "rice msu"

.onLoad <- function(libname, pkgname)
{
	# 获取压缩文件路径
    zipfile <- system.file("extdata", "org.Rmsu.eg.zip", package=pkgname, lib.loc=libname)
    print(zipfile)
    # 定义解压的目标目录，这里假设为包的数据库目录
    zip_dir <- dirname(zipfile)
    print(zip_dir)
    # 解压文件到目标目录
    utils::unzip(zipfile, exdir = zip_dir)

    ## Connect to the SQLite DB
    dbfile <- system.file("extdata", "org.Rmsu.eg.sqlite", package=pkgname, lib.loc=libname)
	print(dbfile)
    assign("dbfile", dbfile, envir=datacache)
    dbconn <- dbFileConnect(dbfile)
    assign("dbconn", dbconn, envir=datacache)

    ## Create the OrgDb object
    sPkgname <- sub(".db$","",pkgname)
    db <- loadDb(system.file("extdata", paste(sPkgname,
      ".sqlite",sep=""), package=pkgname, lib.loc=libname),
                   packageName=pkgname)    
    dbNewname <- AnnotationDbi:::dbObjectName(pkgname,"OrgDb")
    ns <- asNamespace(pkgname)
    assign(dbNewname, db, envir=ns)
    namespaceExport(ns, dbNewname)
        
    packageStartupMessage(AnnotationDbi:::annoStartupMessages("org.Rmsu.eg.db"))
}

.onUnload <- function(libpath)
{
    dbFileDisconnect(org.Rmsu.eg_dbconn())
}

