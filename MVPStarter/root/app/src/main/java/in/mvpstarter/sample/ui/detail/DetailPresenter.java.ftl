package ${packageName}.features.detail;


import javax.inject.Inject;

import ${packageName}.data.DataManager;
import ${packageName}.data.model.Pokemon;
import ${packageName}.data.model.Statistic;
import ${packageName}.injection.ConfigPersistent;
import ${packageName}.features.base.BasePresenter;
import rx.SingleSubscriber;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;
import rx.subscriptions.CompositeSubscription;
import timber.log.Timber;

@ConfigPersistent
public class DetailPresenter extends BasePresenter<DetailMvpView> {

    private final DataManager mDataManager;
    private CompositeSubscription mSubscriptions;

    @Inject
    public DetailPresenter(DataManager dataManager) {
        mDataManager = dataManager;
    }

    @Override
    public void attachView(DetailMvpView mvpView) {
        super.attachView(mvpView);
        mSubscriptions = new CompositeSubscription();
    }

    @Override
    public void detachView() {
        super.detachView();
        mSubscriptions.unsubscribe();
        mSubscriptions = null;
    }

    public void getPokemon(String name) {
        checkViewAttached();
        getMvpView().showProgress(true);
        mSubscriptions.add(mDataManager.getPokemon(name)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe(new SingleSubscriber<Pokemon>() {
                    @Override
                    public void onSuccess(Pokemon pokemon) {
                        getMvpView().showProgress(false);
                        getMvpView().showPokemon(pokemon);
                        for (Statistic statistic : pokemon.stats) {
                            getMvpView().showStat(statistic);
                        }
                    }

                    @Override
                    public void onError(Throwable error) {
                        getMvpView().showProgress(false);
                        getMvpView().showError();
                        Timber.e(error, "There was a problem retrieving the pokemon...");
                    }
                }));
    }


}
