import ctdtoptimizer as ct
import gui


def main():
    """main method for ctdt optimizer"""
    # construct class object
    opt = ct.CTDTOptimizer()
    # gui.Gui()

    # display for each position
    opt.display_ranked()

    return 0
