"read.fasta" <-
function(file, rm.dup=TRUE, to.upper=FALSE, to.dash=TRUE) {

  cl <- match.call(); raw.fa <- scan(file, what=character(0), sep="\n", quiet = TRUE)
  ind <- grep(">", raw.fa) ## seq id lines
  if(length(ind) == 0) {    stop("read.fasta: no '>' id lines found, check file format")  }
  
  if (to.dash) { raw.fa[-ind] <- gsub("[/.]","-", raw.fa[-ind]) }
  if (to.upper) { raw.fa[-ind] <- toupper(raw.fa[-ind]) }  
  
  ind.s <- ind+1 ;ind.e <- c((ind-1)[-1], length(raw.fa))  ## seq start and end lines

  seq.dim <-  apply(cbind(ind.s, ind.e), 1,function(x) sum( nchar(raw.fa[ (x[1]:x[2])]) ))

  seq.format <- function(x, max.seq=max(seq.dim)) { fa <- rep("-",max.seq)
  fa[ c(1:x[3]) ] <- unlist(strsplit( raw.fa[ (x[1]:x[2]) ], split=""));
    return(fa)
  }
	store.fa <- t(matrix(apply(cbind(ind.s, ind.e, seq.dim), 1, seq.format), ncol=length(ind)))
  	rownames(store.fa) <- gsub("^>| .*", "",raw.fa[ind], perl=TRUE)

  if (rm.dup) { dups <- duplicated(row.names(store.fa))
    if (any(dups)) { print(paste(" ** Duplicated sequence id's: ",row.names(store.fa)[dups]," **",sep=""))
      store.fa <- store.fa[!dups,]     }   }
  
  output <- list(id=rownames(store.fa), ali=store.fa, call=cl)
  class(output) <- "fasta";  return(output) 
}

