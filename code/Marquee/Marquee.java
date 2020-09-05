import java.applet.*;
import java.awt.*;

public class Marquee extends Applet implements Runnable {

	private int sleepyTime = 0, shadowOffset = 0, decrement = 2;
	private Dimension APPLET;	
	private Color BGCOLOUR;	
	private String text, font;
	private ScrollText scrollText;	
  	private double fontScale = 0.8; 
	private boolean RUNNING = false, dropShadow, grayShadow;
	private Thread TEXTTHREAD;
	
	public void init() {
		int BGRed = 255, BGGreen = 255, BGBlue = 255, textRed = 0, textGreen = 0, textBlue = 0;

		// PARAMETERS FROM APPLET //
		font = Font.decode(getParameter("Font")).toString();
		font = font.substring(font.indexOf("e=") + 2, font.indexOf(",style="));

		text = getParameter("ScrollingText");
		if (text == "") {
			text = "Know Thyself...";	
		}
		try {
			decrement = withinBounds(1, 100, Integer.parseInt(getParameter("ScrollSmoothness")));
			sleepyTime = withinBounds(1, 1000, Integer.parseInt(getParameter("ScrollDelay")));
			BGRed = withinBounds(0, 255, Integer.parseInt(getParameter("BGRed")));
			BGGreen = withinBounds(0, 255, Integer.parseInt(getParameter("BGGreen")));
			BGBlue = withinBounds(0, 255, Integer.parseInt(getParameter("BGBlue")));
			textRed = withinBounds(0, 255, Integer.parseInt(getParameter("TextRed")));
			textGreen = withinBounds(0, 255, Integer.parseInt(getParameter("TextGreen")));
			textBlue = withinBounds(0, 255, Integer.parseInt(getParameter("TextBlue")));
		} catch (Exception e) {
			showStatus("Parameter not a valid Number : " + e);
		}
		dropShadow = Boolean.valueOf(getParameter("DropShadow")).booleanValue();
		grayShadow = Boolean.valueOf(getParameter("GreyShadow")).booleanValue();;		
		
		// get Applet Dimensions
		APPLET = new Dimension (this.getSize().width, this.getSize().height);
		
		// set offset as proportion of height		
		shadowOffset = APPLET.height / 25;

		// set background colour 
		BGCOLOUR = new Color(BGRed, BGGreen, BGBlue);
		setBackground(BGCOLOUR);

		// create scrolling text object
		scrollText = new ScrollText((new Color (textRed, textGreen, textBlue)), 
							  getFontMetrics(new Font(font, Font.PLAIN, ((int)(APPLET.height * fontScale)))),
							  ((int)(APPLET.height * fontScale)),
							  APPLET.width,	
							  text);
		// go
		RUNNING = true;
		TEXTTHREAD = new Thread(this);
		TEXTTHREAD.start();
	}

	public void run () {
		while (RUNNING) {
			repaint();
			try {
				Thread.sleep(sleepyTime);
			} catch (InterruptedException ie) {
				RUNNING = false;
			}	
		}
	}

	public int withinBounds(int min, int max, int value) {
		if (value < min) {
			return (min);
		}
		else if (value > max) {
			return (max);
		}
		return (value);
	}

	public void stop() {
		RUNNING = false;
	}

	public void update(Graphics g) {
		if (RUNNING) {
			paint(g);
		}
	}

	public void paint(Graphics g) {
		if (RUNNING){
			// get offscreen object to make drawing smoother
			Image offScreen = createImage(APPLET.width, APPLET.height);
			Graphics graphics = offScreen.getGraphics();
	
			// move position of text 
			scrollText.setHorizontalPos(scrollText.getHorizontalPos() - decrement);
			
			// if gone off screen reset 
			if (scrollText.getHorizontalPos() <= (0 - scrollText.getWidth())) {
				scrollText.setHorizontalPos(APPLET.width);				
			}
			
			// clear previous screen
			graphics.setColor(BGCOLOUR);
			graphics.fillRect(0,0,APPLET.width,APPLET.height);
			
			// draw the dropshadow according to font and boolean parameters
			graphics.setFont(scrollText.getFontMetrics().getFont());
			if (dropShadow) {
				if (!grayShadow) {
					graphics.setColor(scrollText.getColor().darker());
				}
				else	{
					graphics.setColor(Color.gray);
				}
				graphics.drawString(scrollText.getText(), (scrollText.getHorizontalPos() + shadowOffset), scrollText.getFontMetrics().getAscent());
			}
			
			// draw the scrolling text
			graphics.setColor(scrollText.getColor());
			graphics.drawString(scrollText.getText(), scrollText.getHorizontalPos(), (scrollText.getFontMetrics().getAscent() - shadowOffset));
			
			// send it to the screen
			g.drawImage(offScreen, 0, 0, this);
		}
	}
}


class ScrollText {
	private Color 		color;
	private FontMetrics 	fontMetrics;
	private int 		height;
	private int 		horizontalPos;
	private String 		text;
		
	public ScrollText (Color color, FontMetrics fontMetrics, int height, int horizontalPos, String text) {
		this.color = color;
		this.fontMetrics = fontMetrics;
		this.height = height;
		this.horizontalPos = horizontalPos;
		this.text = text;
	}
	
      public void setColor(Color color) {
		this.color = color; 		
	}

      public Color getColor() {
		return(this.color); 		
	}

      public Font getFont() {
		return(this.fontMetrics.getFont()); 		
	}

	public void setFontMetrics(FontMetrics fontMetrics) {
		this.fontMetrics = fontMetrics; 		
	}

      public FontMetrics getFontMetrics() {
		return(this.fontMetrics); 		
	}

      public void setHeight(int height) {
		this.height = height; 		
	}

      public int getHeight() {
		return(this.height); 		
	}

      public void setHorizontalPos(int horizontalPos) {
		this.horizontalPos = horizontalPos; 		
	}

      public int getHorizontalPos() {
		return(this.horizontalPos); 		
	}

	public String toString () {
		return ("\nColour = " + this.color.toString() +
			  "\nfontMetrics = " + this.fontMetrics.toString() +
			  "\nHeight =" + this.height +
			  "\nHorizontalPos = " + this.horizontalPos +
			  "\nText = " + this.text);
	}

      public void setText(String text) {
		this.text = text; 		
	}

      public String getText() {
		return(this.text); 		
	}

      public int getWidth() {
		return(this.fontMetrics.stringWidth(this.text)); 		
	}
}