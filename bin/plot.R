#/usr/bin/R
#library(DESeq2)
#library(agricolae)
library(ggplot2)
#library(EnhancedVolcano)
library(reshape2)
library(scales)

zdp <- read.csv('result/result_AUCG.txt',header = T,sep = "\t")
colnames(zdp) <- c('length','A','U','C','G','treat','sample')
zdp$rowsum <- rowSums(zdp[,2:5])
yaml <- read.csv('result/result_counts.txt',header = T,row.names = 1,sep = "\t")
group <- read.csv('file.list',header = F,sep = "\t")
i=4;j=16
t1 <- zdp[i:j,]
name <- zdp[i,'sample']
t1$rowsum <- t1$rowsum*10^6/yaml[name,1]
t1$A <- t1$A*10^6/yaml[name,1]
t1$U <- t1$U*10^6/yaml[name,1]
t1$C <- t1$C*10^6/yaml[name,1]
t1$G <- t1$G*10^6/yaml[name,1]
for (n in 1:(nrow(yaml)-1)) {
  i=i+36;j=j+36
  t2 <- zdp[i:j,]
  name <- zdp[i,'sample']
  t2$rowsum <- t2$rowsum*10^6/yaml[name,1]
  t1$A <- t1$A*10^6/yaml[name,1]
  t1$U <- t1$U*10^6/yaml[name,1]
  t1$C <- t1$C*10^6/yaml[name,1]
  t1$G <- t1$G*10^6/yaml[name,1]
  t1 <- rbind(t1,t2)
}
zdpdata <- melt(t1,id.vars=c("length",'sample','treat','A','U','C','G'),variable.name="type",value.name = "counts")
zdpdata$sample <- factor(zdpdata$sample,levels=group[,1])
p <- ggplot(zdpdata,aes(length,counts,fill=sample))+geom_bar(stat = "identity",position = "dodge")+theme_classic()+scale_y_continuous(labels = comma,expand = c(0,0))+scale_fill_brewer(palette="Set2")+theme(axis.line.x = element_line(size = 1),axis.line.y = element_line(size = 1))+xlab(NULL)+ylab('normalized sRNA reads')
#scale_fill_manule(values = c('#d4d4d4','#ffc080','#55a0fb','#ff8080'))
pdf("length_distribution.pdf",width = 6,height = 6)
print(p)
dev.off()

i=4;j=16
t1 <- zdp[i:j,]
t1$A <- t1$A*10^6/sum(t1$rowsum)
t1$U <- t1$U*10^6/sum(t1$rowsum)
t1$C <- t1$C*10^6/sum(t1$rowsum)
t1$G <- t1$G*10^6/sum(t1$rowsum)
for (n in 1:(nrow(yaml)-1)) {
  i=i+36;j=j+36
  t2 <- zdp[i:j,]
  t2$A <- t2$A*10^6/sum(t2$rowsum)
  t2$U <- t2$U*10^6/sum(t2$rowsum)
  t2$C <- t2$C*10^6/sum(t2$rowsum)
  t2$G <- t2$G*10^6/sum(t2$rowsum)
  t1 <- rbind(t1,t2)
}
augcdata <- melt(t1,id.vars=c("length",'sample','treat','rowsum'),variable.name="type",value.name = "counts")
augcdata$sample <- factor(augcdata$sample,levels=group[,1])
test <- subset(augcdata,augcdata$length=="21")
q <- ggplot(test,aes(type,counts,fill=sample))+geom_bar(stat = "identity",position = "dodge")+theme_classic()+scale_y_continuous(labels = comma,expand = c(0,0))+scale_fill_brewer(palette="Set2")+theme(axis.line.x = element_line(size = 1),axis.line.y = element_line(size = 1))+xlab(NULL)+ylab('normalized sRNA reads')
#scale_fill_manual(values = c('#d4d4d4','#ffc080','#55a0fb','#ff8080'))
pdf("AUGC_frequence.pdf",width = 6,height = 6)
print(q)
dev.off()

maplot <- read.csv("result/result_diff.txt",header = TRUE,row.names = 1,sep = "\t")
len_col <- dim(maplot)[2]
for(i in 1:len_col){
maplot[,i] <- maplot[,i]*10^6/yaml[i,1]
}
maplot$Col.0 <- mean(maplot[,3:4])
maplot$zdp.1ape2.2 <- mean(maplot[,1:2])
maplot <- maplot+0.01
maplot$Log2 <- log2(maplot$Col.0/maplot$zdp.1ape2.2)
maplot$sig <- ifelse(abs(maplot$Log2)>=0.58,ifelse(maplot$Log2>=0.58,"Down","Up"),"Stable")
maplot$sig <- factor(maplot$sig,levels = c('Up','Down','Stable')
maplot <- maplot[order(maplot$sig,decreasing = TRUE),]
maplot$Col.0 <- log2(maplot$Col.0)
maplot$zdp.1ape2.2 <- log2(maplot$zdp.1ape2.2)
maplot$zdp.1ape2.2 <- 0+(5/(max(maplot$zdp.1ape2.2)-min(maplot$zdp.1ape2.2)))*(maplot$zdp.1ape2.2-min(maplot$zdp.1ape2.2))
maplot$Col.0 <- 0+(5/(max(maplot$Col.0)-min(maplot$Col.0)))*(maplot$Col.0-min(maplot$Col.0))
g <- ggplot(maplot,aes(x=Col.0,y=zdp.1ape2.2))+
  geom_point(aes(color=sig),size=1.5)+
  scale_color_manual(values = c("Up"='#ffc080',"Stable"='gray',"Down"='#55a0fb'))+theme_classic()+scale_x_continuous(limits = c(0,5))
pdf("ma-plot.pdf",width = 6,height = 6)
print(g)
dev.off()


piedata <- as.data.frame(table(maplot$sig))
h <- ggplot(piedata,aes(x="",y=Freq,fill=Var1))+geom_bar(stat = "identity")+coord_polar("y",start = 0)+scale_fill_manual(values=c("Stable"="#999999", "Up"="#E69F00", "Down"="#56B4E9"))+labs(x="")+geom_text(aes(y=Freq/3+c(0,cumsum(Freq)[-length(Freq)]),label=scales:::percent(Freq/sum(Freq)),size=5))
pdf("pieplot.pdf",width = 6,height = 6)
print(h)
dev.off()


