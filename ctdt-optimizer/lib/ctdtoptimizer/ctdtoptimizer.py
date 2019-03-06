import os.path as path
import pandas as pd
import ruamel.yaml as yaml


class CTDTOptimizer(object):
    """tool to optimize positions in ctdt

       typically we construct with a params file providing inputs

       then we display rankings for desired positions"""
    # constructor
    def __init__(self):
        # grab dataframes from maintained spreadsheets
        self.df = pd.read_excel('https://docs.google.com/spreadsheets/u/1/d/'
                                '1E9rwAbRXrU2wjjMe6521z2HxMQnPKdVY8RfVzxzCzyE'
                                '/export?format=xlsx&id=1E9rwAbRXrU2w'
                                'jjMe6521z2HxMQnPKdVY8RfVzxzCzyE',
                                sheet_name=None)
        self.sk_df = pd.read_excel('https://docs.google.com/spreadsheets/'
                                   'u/1/d/1mj9cpGHDmqj0eDWVblyPNEPbeX6puRMgo'
                                   '0uxbQrYMb8/export?format=xlsx&id=1mj9cpG'
                                   'HDmqj0eDWVblyPNEPbeX6puRMgo0uxbQrYMb8',
                                   sheet_name=None)
        # load params
        params_file = (path.dirname(path.abspath(__file__)) +
                       '/../../data/params.yaml')
        params = yaml.safe_load(open(params_file).read())
        self.__weights = params['weights']
        self.__sort = params['sort']
        self.__positions = self.__weights.keys()
        # create a new dataframe for cleaner output
        self.__new_df = self.__create_dataframe()

    # public
    def display_ranked(self):
        """display rankings for selected positions"""
        for position in self.__positions:
            # calculate the rank for a position and add to new dataframe
            self.__calculate_rank(position=position)
            # output new dataframe
            new_df = self.__new_df[position].sort_values(by=[self.__sort],
                                                         ascending=False)
            print(new_df.reset_index(drop=True))

    # private
    def __create_dataframe(self):
        """create a new dataframe"""
        # init a dict to hold dataframes
        new_df = {}

        for position in self.__positions:
            # create a dataframe for a position
            new_df[position] = pd.DataFrame(data={})
            # populate the position dataframe with necessary info
            new_df[position]['Name'] = self.df[position]['Name']
            new_df[position]['Title'] = self.df[position]['Title']
            new_df[position]['Class'] = self.df[position]['Class']

        # return the modified dataframe
        return new_df

    def __calculate_rank(self, position):
        """calculate the rank for a position"""
        # pare down dict to save time on lookups
        # this is a shallow copy so we retain modifications to it
        new_df = self.__new_df[position]

        # determine new weighted ranking column
        new_df['Weighted'] = self.__calculate_weighted(position=position)

        # calculate new scaled column
        new_df['Scaled'] = new_df['Weighted'] / self.df[position]['Total']

    def __calculate_weighted(self, position):
        """calculates the weighted ranking for a position"""
        # pare down dicts to save time on lookups
        weights = self.__weights[position]
        df = self.df[position]

        if position == 'GK':
            # calculate weighted ranking metric
            return (weights['Punch'] *
                    (df['Punch'] + ((df['Power'] + df['Speed']) / 4.0)) +
                    weights['Catch'] *
                    (df['Catch'] + ((df['Power'] + df['Technique']) / 4.0)))
        return (weights['Dribble'] *
                (df['Dribble'] + (df['Speed'] / 2.0)) +
                weights['Shot'] *
                (df['Shot'] + (df['Power'] / 2.0)) +
                weights['Pass'] *
                (df['Pass'] + (df['Technique'] / 2.0)) +
                weights['Tackle'] *
                (df['Tackle'] + (df['Speed'] / 2.0)) +
                weights['Block'] *
                (df['Block'] + (df['Power'] / 2.0)) +
                weights['Intercept'] *
                (df['Intercept'] + (df['Technique'] / 2.0)))
