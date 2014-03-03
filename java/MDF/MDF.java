package com.nexr.mdf;

import java.io.File;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.nexr.mdf.blocks.DGBlock;
import com.nexr.mdf.blocks.HDBlock;
import com.nexr.mdf.blocks.IDBlock;
import com.nexr.mdf.blocks.MDFByteHandler;
import com.nexr.mdf.blocks.PRBlock;
import com.nexr.mdf.blocks.TXBlock;
import com.nexr.mdf.utils.FileUtils;

public class MDF {
	private static final Logger logger = LoggerFactory.getLogger(MDF.class);
	private IDBlock idBlock;
	private HDBlock hdBlock;
	private TXBlock hdFileComment;
	private PRBlock hdPrBlock;
	private DGBlock firstDGBlock;
	private byte[] fileContents;
	private MDFByteHandler byteHandler;
	
	private void init() {
		this.idBlock = new IDBlock(byteHandler);
		this.hdBlock = new HDBlock(byteHandler);
	}
	public MDF(File file) {
		try {
			this.fileContents = FileUtils.readFromFile(file);
			this.byteHandler = new MDFByteHandler(this.fileContents);
			init();
		} catch ( Exception e ) {
			logger.error("cannot create MDF class", e);
		}
	}
	public IDBlock getIdBlock() {
		return idBlock;
	}
	public void setIdBlock(IDBlock idBlock) {
		this.idBlock = idBlock;
	}
	public HDBlock getHdBlock() {
		return hdBlock;
	}
	public void setHdBlock(HDBlock hdBlock) {
		this.hdBlock = hdBlock;
	}
	public TXBlock getHdFileComment() {
		return hdFileComment;
	}
	public void setHdFileComment(TXBlock hdFileComment) {
		this.hdFileComment = hdFileComment;
	}
	public PRBlock getHdPrBlock() {
		return hdPrBlock;
	}
	public void setHdPrBlock(PRBlock hdPrBlock) {
		this.hdPrBlock = hdPrBlock;
	}
	public DGBlock getFirstDGBlock() {
		return firstDGBlock;
	}
	public void setFirstDGBlock(DGBlock firstDGBlock) {
		this.firstDGBlock = firstDGBlock;
	}
}
