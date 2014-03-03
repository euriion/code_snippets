library(ggplot2)

bp <- ggplot(PlantGrowth, aes(x=group, y=weight)) + geom_boxplot()
bp

bp + coord_flip()

# Manually set the order of a discrete-valued axis
bp + scale_x_discrete(limits=c("trt1","trt2","ctrl"))

# Reverse the order of a discrete-valued axis
# Get the levels of the factor
flevels <- levels(PlantGrowth$group)
# "ctrl" "trt1" "trt2"
# Reverse the order
flevels <- rev(flevels)
# "trt2" "trt1" "ctrl"
bp + scale_x_discrete(limits=flevels)

# Or it can be done in one line:
bp + scale_x_discrete(limits = rev(levels(PlantGrowth$group)))
bp + scale_x_discrete(breaks=c("ctrl", "trt1", "trt2"), labels=c("Control", "Treat 1", "Treat 2"))

# Hide x tick marks, labels, and grid lines
bp + scale_x_discrete(breaks=NULL)

# Hide all tick marks and labels (on X axis), but keep the gridlines
bp + theme(axis.ticks = element_blank(), axis.text.x = element_blank())


# Set the range of a continuous-valued axis
# These are equivalent
bp + ylim(0,8)
bp + scale_y_continuous(limits=c(0,8))



