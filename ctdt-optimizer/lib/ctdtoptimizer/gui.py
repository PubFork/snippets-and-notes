import tkinter as tk
import tkinter.ttk as ttk


class Gui(object):
    """gui frontend for the ctdt optimizer"""
    # constructor
    def __init__(self):
        # initialize tkinter and mainframe
        tkinter = tk.Tk()
        mainframe = ttk.Frame(tkinter, padding='3 3 3 3')

        # setup bounds and title
        tkinter.title('CTDT Optimizer')
        mainframe.grid(column=0, row=0, sticky=(tk.N, tk.W, tk.E, tk.S))
        mainframe.columnconfigure(0, weight=1)
        mainframe.rowconfigure(0, weight=1)

        # setup positions
        fw = tk.StringVar()
        am = tk.StringVar()
        dm = tk.StringVar()
        df = tk.StringVar()
        gk = tk.StringVar()

        # setup entry labels; can use textvariable instead of text to output value set during program executiong
        ttk.Label(mainframe, text='Forward').grid(column=1, row=1, sticky=tk.W)
        fw_entry = ttk.Entry(mainframe, width=5, textvariable=fw)
        fw_entry.grid(column=2, row=1, sticky=(tk.W, tk.E))

        ttk.Label(mainframe,
                  text='Attacking Midfielder').grid(column=1, row=2, sticky=tk.W)
        am_entry = ttk.Entry(mainframe, width=5, textvariable=am)
        am_entry.grid(column=2, row=2, sticky=(tk.W, tk.E))

        ttk.Label(mainframe,
                  text='Defensive Midfielder').grid(column=1, row=3, sticky=tk.W)
        dm_entry = ttk.Entry(mainframe, width=5, textvariable=dm)
        dm_entry.grid(column=2, row=3, sticky=(tk.W, tk.E))

        ttk.Label(mainframe,
                  text='Defender').grid(column=1, row=4, sticky=tk.W)
        df_entry = ttk.Entry(mainframe, width=5, textvariable=df)
        df_entry.grid(column=2, row=4, sticky=(tk.W, tk.E))

        ttk.Label(mainframe,
                  text='Goalkeeper').grid(column=1, row=5, sticky=tk.W)
        gk_entry = ttk.Entry(mainframe, width=5, textvariable=gk)
        gk_entry.grid(column=2, row=5, sticky=(tk.W, tk.E))

        # setup execution button
        ttk.Button(mainframe,
                   text='Optimize',
                   command=self.__optimize).grid(column=2,
                                                 row=6,
                                                 sticky=tk.W)

        # finish it off
        for child in mainframe.winfo_children():
            child.grid_configure(padx=3, pady=3)

        tkinter.bind('<Return>', self.__optimize)
        fw_entry.focus()
        tkinter.mainloop()

    # entry into main program
    def __optimize(self):
        print('Hi')
