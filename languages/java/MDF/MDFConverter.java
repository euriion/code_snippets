package com.nexr.mdf;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.nexr.mdf.blocks.CGBlock;
import com.nexr.mdf.blocks.CNBlock;
import com.nexr.mdf.blocks.DGBlock;
import com.nexr.mdf.blocks.HDBlock;
import com.nexr.mdf.utils.FileUtils;


public class MDFConverter implements Runnable {
	//private static final int THREAD_POOL_SIZE = Runtime.getRuntime().availableProcessors();
	private static final int THREAD_POOL_SIZE = 1;
	private static final ExecutorService executorService = Executors.newFixedThreadPool(THREAD_POOL_SIZE);
	private static final Logger logger = LoggerFactory.getLogger(MDFConverter.class);
	private static String SEPERATOR = "\t";
	private DateFormat FORMAT = new SimpleDateFormat("HH:mm:ss dd:MM:yyyy");
	private DateFormat OUTPUT_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.S");
	private File MDFFile;
	private String outputDir;
	
	private static void initDir(String outputDir) {
		File file = new File(outputDir);
		if ( file.exists() ) {
			throw new RuntimeException("output dir already exists : " + outputDir);
		}
		file.mkdirs();
	}
	
	public MDFConverter(File MDFFile, String outputDir) {
		this.MDFFile = MDFFile;
		outputDir += File.separator;
		this.outputDir = outputDir;
	}
	
	private String generateFileName(String outputDir, int dgSeq, int cgSeq) {
		return outputDir + File.separator + dgSeq + "_" + cgSeq + ".csv";
	}
	
	private void writeDgBlockDescription(DGBlock dgBlock, String outputPath, int dgSeq) {
		try {
			String filePath = outputPath + File.separator + dgSeq + ".desc";
			FileUtils.writeToFile(dgBlock.toString(), filePath, true);
		} catch ( Exception e ) {
			logger.error("cannot write DGBlock description", e);
		}
	}
	
	private void writeCgBlockDescription(CGBlock cgBlock, String outputPath, int dgSeq, int cgSeq) {
		try {
			String filePath = outputPath + File.separator + dgSeq + "_" + cgSeq + ".desc";
			FileUtils.writeToFile(cgBlock.toString(), filePath, true);
		} catch ( Exception e ) {
			logger.error("cannot write CGBlock description", e);
		}
	}
	
	private void writeHdBlockDescription(HDBlock hdBlock, String outputPath) {
		try {
			String filePath = outputPath + File.separator + "header.desc";
			FileUtils.writeToFile(hdBlock.toString(), filePath, true);
		} catch ( Exception e ) {
			logger.error("cannot write HDBlock description", e);
		}
	}
	
	@SuppressWarnings("rawtypes")
	private static Future threadConverterStart(File file, String outputDir) {
		MDFConverter converter = new MDFConverter(file, outputDir);
		logger.info("file name : {}", file.getName());
		Future f = executorService.submit(converter);
		return f;
	}
	
	private static void doConvert(String path, String outputDir) throws ExecutionException, InterruptedException {
		File file = new File(path);
		if ( ! file.exists() ) {
			logger.error("input path is not a file or directory. " + path );
			return;
		}
		logger.info("convert mdf file process start");
		if ( file.isDirectory() ) {
			@SuppressWarnings("rawtypes")
			List<Future> futures = new ArrayList<Future>();
			for ( File f : file.listFiles() ) {
				new MDFConverter(f, outputDir).parseAndWrite();
				futures.add(threadConverterStart(f, outputDir));
			}
			for ( @SuppressWarnings("rawtypes") Future f : futures ) {
				f.get();
			}
		} else {
			new MDFConverter(file, outputDir).parseAndWrite();
			threadConverterStart(file, outputDir).get();
		}
		logger.info("convert finished successfully...");
		executorService.shutdownNow();
	}

	public static void main(String[] args) {
		if ( args.length == 0 ) {
			System.out.println("usage : MDFWriter.sh input_dir_or_file_path output_dir_path [seperator]");
			return;
		}
		String path = args[0];
		String outputDir = args[1];
		if ( args.length > 3 ) {
			SEPERATOR = args[2];
		}
		initDir(outputDir);
		try {
			doConvert(path, outputDir);
		} catch ( Exception e ) {
			logger.error("an interrupted accured...", e);
			return;
		}
	}
	
	@Override
	public void run() {
		parseAndWrite();
	}
	
	private void writeHeader(BufferedWriter os, List<CNBlock> cnBlocks) throws IOException {
		os.write("file" + SEPERATOR);
		os.write("start_time" + SEPERATOR);
		for ( int i = 0; i < cnBlocks.size(); i ++ ) {
			CNBlock b = cnBlocks.get(i);
			String header = b.getShortSignalName().replaceAll("\\\\A$", "");
			header = header.toLowerCase();
			header = header.replaceAll("[^a-z,0-9]", "_");
			header = header.replaceAll("[_]+", "_");
			header = header.replaceAll("[_]$", "");
			
			if ( b.getChannelType() == 1 ) {
				os.write("checked_time" + SEPERATOR);
			}
			
			os.write(header);
			if ( i < cnBlocks.size() - 1) os.write(SEPERATOR);
		}
		os.newLine();
	}
	
	public void writeBody(BufferedWriter os, List<CNBlock> cnBlocks, CGBlock cgBlock, String fileName, long startTime) throws IOException {
		for ( int i = 0; i < cgBlock.getNumberOfRecords(); i ++ ) {
			os.write(fileName + SEPERATOR);
			os.write(OUTPUT_FORMAT.format(new Date(startTime))+ SEPERATOR);
			for ( int j = 0; j < cnBlocks.size(); j ++ ) {
				CNBlock b= cnBlocks.get(j);
				if ( b.getChannelType() == 1 ) {
					String date = OUTPUT_FORMAT.format(new Date((long)(Double.parseDouble(b.getData(i))*1000 + startTime)));
					os.write(date + SEPERATOR);
					os.write(b.getData(i));
				} else {
					try {
						os.write(b.getData(i));
					} catch ( IndexOutOfBoundsException e ) {
						logger.error("file is currupted...", e);
						break;
					}
				}
				if ( j < cnBlocks.size() - 1) os.write(SEPERATOR);
			}
			os.newLine();
		}
	}
	
	private long getDate(HDBlock hdBlock) {
		String startTime = hdBlock.getTimeOfRecordingStart();
		String startDate = hdBlock.getDateOfRecordingStart();
		String dateTime = startTime + " " + startDate;
		
		Date date = null;
		try {
			date = FORMAT.parse(dateTime);
		} catch ( ParseException e ) {
			logger.error("invalid data type : {} {}", startTime, startDate);
		}

		return date.getTime();
	}
	
	public void parseAndWrite() {
		String outputPath = this.outputDir + MDFFile.getName() + File.separator;
		initDir(outputPath);
		MDF mdf = new MDF(MDFFile);
		HDBlock hdBlock = mdf.getHdBlock();
		writeHdBlockDescription(hdBlock, outputPath);
		if ( hdBlock == null ) {
			logger.error("file parsing error : {}", MDFFile.getName());
			return;
		}
		DGBlock dgBlock =hdBlock.getFirstDGBlock();
		long dateTime = getDate(hdBlock);
		logger.info("recorded date : {}", new Date(dateTime));

		int dgSeq = 0;
		do {
			writeDgBlockDescription(dgBlock, outputPath, dgSeq);
			dgSeq ++;
			CGBlock cgBlock = dgBlock.getCgblock();

			BufferedWriter os = null;
			int cgSeq = 0;
			do {
				try {
					cgSeq++;
					writeCgBlockDescription(cgBlock, outputPath, dgSeq, cgSeq);
					os = new BufferedWriter(new FileWriter(new File(generateFileName(outputPath, dgSeq, cgSeq))));
					CNBlock cnBlock = cgBlock.getFirstChannelBlock();
					List<CNBlock> cnBlocks = new ArrayList<CNBlock>();
					do {
						cnBlocks.add(cnBlock);
					} while ( (cnBlock = cnBlock.getNextChannelBlock()) != null );
					
					writeHeader(os, cnBlocks);
					writeBody(os, cnBlocks, cgBlock, MDFFile.getName(), dateTime);
				} catch ( Exception e ) {
					logger.error("cannot write result file...", e);
					return;
				} finally {
					try{os.close();}catch(Exception e){};
				}
			} while ( (cgBlock = cgBlock.getNextCGBlock()) != null );
		} while ( (dgBlock = dgBlock.getNextDGBlock()) != null );
	}
}
